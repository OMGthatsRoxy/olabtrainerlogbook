import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/course_record.dart' as course_record;
import '../models/exercise.dart';
import '../models/schedule.dart';
import '../services/data_service.dart';
import 'package:provider/provider.dart';

class AddCourseRecordScreen extends StatefulWidget {
  final String clientId;
  final String clientName;
  final DateTime? selectedDate;
  final String? selectedTime; // 添加课程时间参数

  const AddCourseRecordScreen({
    super.key,
    required this.clientId,
    required this.clientName,
    this.selectedDate,
    this.selectedTime, // 添加课程时间参数
  });

  @override
  State<AddCourseRecordScreen> createState() => _AddCourseRecordScreenState();
}

class _AddCourseRecordScreenState extends State<AddCourseRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  // 表单控制器
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _coachRecordController;
  late TextEditingController _studentPerformanceController;
  late TextEditingController _nextGoalController;

  // 表单数据
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '12:00';
  course_record.TrainingMode? _selectedTrainingMode;
  List<course_record.ActionTraining> _actionTrainings = [];
  List<Exercise> _availableExercises = [];

  // 状态管理
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _coachRecordController = TextEditingController();
    _studentPerformanceController = TextEditingController();
    _nextGoalController = TextEditingController();

    // 设置初始值
    if (widget.selectedDate != null) {
      _selectedDate = widget.selectedDate!;
    }
    if (widget.selectedTime != null) {
      _selectedTime = widget.selectedTime!;
    }
    _dateController.text = _formatDate(_selectedDate);
    _timeController.text = _selectedTime;

    // 添加第一个动作训练
    _addActionTraining();

    // 加载可用动作
    _loadExercises();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _coachRecordController.dispose();
    _studentPerformanceController.dispose();
    _nextGoalController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadExercises() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final exercises = await dataService.getAllExercises();

      setState(() {
        _availableExercises = exercises;
      });
    } catch (e) {
      // 忽略错误
    }
  }

  void _addActionTraining() {
    final newAction = course_record.ActionTraining(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: '胸',
      sets: [course_record.ExerciseSet(setNumber: 1)],
    );

    setState(() {
      _actionTrainings.add(newAction);
    });
  }

  void _removeActionTraining(String actionId) {
    setState(() {
      _actionTrainings.removeWhere((action) => action.id == actionId);
    });
  }

  void _addSetToAction(String actionId) {
    setState(() {
      final actionIndex = _actionTrainings.indexWhere(
        (action) => action.id == actionId,
      );
      if (actionIndex != -1) {
        final action = _actionTrainings[actionIndex];
        final newSet = course_record.ExerciseSet(
          setNumber: action.sets.length + 1,
        );
        final updatedAction = course_record.ActionTraining(
          id: action.id,
          category: action.category,
          exerciseName: action.exerciseName,
          exerciseId: action.exerciseId,
          sets: [...action.sets, newSet],
          notes: action.notes,
        );
        _actionTrainings[actionIndex] = updatedAction;
      }
    });
  }

  void _updateActionCategory(String actionId, String category) {
    setState(() {
      final actionIndex = _actionTrainings.indexWhere(
        (action) => action.id == actionId,
      );
      if (actionIndex != -1) {
        final action = _actionTrainings[actionIndex];
        final updatedAction = course_record.ActionTraining(
          id: action.id,
          category: category,
          exerciseName: action.exerciseName,
          exerciseId: action.exerciseId,
          sets: action.sets,
          notes: action.notes,
        );
        _actionTrainings[actionIndex] = updatedAction;
      }
    });
  }

  void _updateActionExercise(
    String actionId,
    String? exerciseName,
    String? exerciseId,
  ) {
    setState(() {
      final actionIndex = _actionTrainings.indexWhere(
        (action) => action.id == actionId,
      );
      if (actionIndex != -1) {
        final action = _actionTrainings[actionIndex];
        final updatedAction = course_record.ActionTraining(
          id: action.id,
          category: action.category,
          exerciseName: exerciseName,
          exerciseId: exerciseId,
          sets: action.sets,
          notes: action.notes,
        );
        _actionTrainings[actionIndex] = updatedAction;
      }
    });
  }

  void _updateSetWeight(String actionId, int setNumber, double? weight) {
    setState(() {
      final actionIndex = _actionTrainings.indexWhere(
        (action) => action.id == actionId,
      );
      if (actionIndex != -1) {
        final action = _actionTrainings[actionIndex];
        final updatedSets = action.sets.map((set) {
          if (set.setNumber == setNumber) {
            return course_record.ExerciseSet(
              setNumber: set.setNumber,
              weight: weight,
              reps: set.reps,
              duration: set.duration,
              notes: set.notes,
            );
          }
          return set;
        }).toList();

        final updatedAction = course_record.ActionTraining(
          id: action.id,
          category: action.category,
          exerciseName: action.exerciseName,
          exerciseId: action.exerciseId,
          sets: updatedSets,
          notes: action.notes,
        );
        _actionTrainings[actionIndex] = updatedAction;
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.parse('2024-01-01 ${_selectedTime}:00'),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        _timeController.text = _selectedTime;
      });
    }
  }

  Future<void> _saveCourseRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final dataService = Provider.of<DataService>(context, listen: false);

      // 创建课程记录
      final courseRecord = course_record.CourseRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: widget.clientId,
        clientName: widget.clientName,
        courseDate: _selectedDate,
        startTime: _selectedTime,
        trainingMode: _selectedTrainingMode,
        actionTrainings: _actionTrainings,
        coachRecord: _coachRecordController.text.trim(),
        studentPerformance: _studentPerformanceController.text.trim(),
        nextGoal: _nextGoalController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 保存课程记录到Firebase
      final courseRecordId = await dataService.addCourseRecord(courseRecord);

      if (courseRecordId != null) {
        // 查找对应的课程并更新状态
        final schedules = await dataService.getSchedules();
        Schedule? matchingSchedule;
        try {
          matchingSchedule = schedules.firstWhere(
            (schedule) =>
                schedule.clientId == widget.clientId &&
                schedule.date.year == _selectedDate.year &&
                schedule.date.month == _selectedDate.month &&
                schedule.date.day == _selectedDate.day &&
                schedule.startTime == _selectedTime,
          );
        } catch (e) {
          // 没有找到匹配的课程
          matchingSchedule = null;
        }

        if (matchingSchedule != null) {
          // 更新课程状态为已完成
          final updateSuccess = await dataService.updateScheduleStatus(
            matchingSchedule.id,
            ScheduleStatus.completed,
            courseRecordId: courseRecordId, // 使用Firebase生成的ID
          );
        } else {
          // 未找到匹配的课程，无法更新状态
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('课程记录保存成功'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('保存课程记录失败');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text('新建课程记录 - ${widget.clientName}'),
        backgroundColor: const Color(0xFF2A2A2A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 课程日期和时间
                    _buildDateTimeSection(),
                    const SizedBox(height: 24),

                    // 训练模式
                    _buildTrainingModeSection(),
                    const SizedBox(height: 24),

                    // 动作训练
                    _buildActionTrainingSection(),
                    const SizedBox(height: 24),

                    // 教练记录
                    _buildCoachRecordSection(),
                    const SizedBox(height: 24),

                    // 学员表现
                    _buildStudentPerformanceSection(),
                    const SizedBox(height: 24),

                    // 下次目标
                    _buildNextGoalSection(),
                    const SizedBox(height: 32),

                    // 底部按钮
                    _buildBottomButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '课程日期',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '课程开始时间',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _timeController,
          readOnly: true,
          onTap: _selectTime,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: const Icon(Icons.access_time, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '训练模式',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<course_record.TrainingMode>(
            value: _selectedTrainingMode,
            hint: const Text('选择训练模式', style: TextStyle(color: Colors.grey)),
            dropdownColor: const Color(0xFF2A2A2A),
            style: const TextStyle(color: Colors.white),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            decoration: const InputDecoration(border: InputBorder.none),
            items: course_record.TrainingMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(_getTrainingModeText(mode)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTrainingMode = value;
              });
            },
          ),
        ),
      ],
    );
  }

  String _getTrainingModeText(course_record.TrainingMode mode) {
    switch (mode) {
      case course_record.TrainingMode.strength:
        return '力量训练';
      case course_record.TrainingMode.cardio:
        return '有氧训练';
      case course_record.TrainingMode.flexibility:
        return '柔韧性训练';
      case course_record.TrainingMode.functional:
        return '功能性训练';
      case course_record.TrainingMode.hiit:
        return '高强度间歇训练';
      case course_record.TrainingMode.yoga:
        return '瑜伽';
      case course_record.TrainingMode.pilates:
        return '普拉提';
      case course_record.TrainingMode.boxing:
        return '拳击';
      case course_record.TrainingMode.swimming:
        return '游泳';
      case course_record.TrainingMode.other:
        return '其他';
    }
  }

  Widget _buildActionTrainingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '动作训练',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._actionTrainings.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return _buildActionTrainingCard(action, index + 1);
        }).toList(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addActionTraining,
            icon: const Icon(Icons.add),
            label: const Text('增加动作'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTrainingCard(
    course_record.ActionTraining action,
    int actionNumber,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '动作$actionNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _removeActionTraining(action.id),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 选择分类
          const Text(
            '选择分类',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildCategorySelector(action),
          const SizedBox(height: 16),

          // 选择动作
          const Text(
            '选择动作',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildExerciseSelector(action),
          const SizedBox(height: 16),

          // 添加新动作按钮
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: 跳转到添加新动作页面
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF667eea),
                side: const BorderSide(color: Color(0xFF667eea)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('添加新动作'),
            ),
          ),
          const SizedBox(height: 16),

          // 组数设置
          _buildSetsSection(action),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(course_record.ActionTraining action) {
    final categories = ['胸', '背', '肩膀', '手臂', '臀', '腿', '全身'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = action.category == category;
        return GestureDetector(
          onTap: () => _updateActionCategory(action.id, category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF667eea) : Colors.transparent,
              border: Border.all(
                color: isSelected ? const Color(0xFF667eea) : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExerciseSelector(course_record.ActionTraining action) {
    // 创建分类映射，将简化名称映射到完整名称
    final categoryMapping = {
      '胸': '胸部', // 映射到完整名称
      '背': '背部', // 映射到完整名称
      '肩膀': '肩部', // 映射到完整名称
      '手臂': '手臂', // 保持与动作库一致
      '臀': '臀部', // 映射到完整名称
      '腿': '腿部', // 映射到完整名称
      '全身': '全身', // 保持与动作库一致
    };

    final targetCategory = categoryMapping[action.category] ?? action.category;

    final exercisesInCategory = _availableExercises
        .where((exercise) => exercise.bodyPart == targetCategory)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: action.exerciseId,
        hint: Text(
          exercisesInCategory.isEmpty ? '该分类暂无动作 (${targetCategory})' : '选择动作',
          style: const TextStyle(color: Colors.grey),
        ),
        dropdownColor: const Color(0xFF1A1A1A),
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        decoration: const InputDecoration(border: InputBorder.none),
        items: exercisesInCategory.map((exercise) {
          return DropdownMenuItem(
            value: exercise.id,
            child: Text(exercise.name),
          );
        }).toList(),
        onChanged: exercisesInCategory.isEmpty
            ? null
            : (value) {
                final exercise = exercisesInCategory.firstWhere(
                  (e) => e.id == value,
                );
                _updateActionExercise(action.id, exercise.name, exercise.id);
              },
      ),
    );
  }

  Widget _buildSetsSection(course_record.ActionTraining action) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '重量(kg)',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ...action.sets.map((set) => _buildSetRow(action.id, set)).toList(),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _addSetToAction(action.id),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('加一组'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF667eea),
              side: const BorderSide(color: Color(0xFF667eea)),
              padding: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetRow(String actionId, course_record.ExerciseSet set) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '第${set.setNumber}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              initialValue: set.weight?.toString() ?? '',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '重量(kg)',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF667eea)),
                ),
              ),
              onChanged: (value) {
                final weight = double.tryParse(value);
                _updateSetWeight(actionId, set.setNumber, weight);
              },
            ),
          ),
          // 添加删除按钮（只有当组数大于1时才显示）
          if (_getActionSetsCount(actionId) > 1)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _removeSetFromAction(actionId, set.setNumber),
            ),
        ],
      ),
    );
  }

  Widget _buildCoachRecordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '教练记录',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _coachRecordController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '记录教练的观察和建议...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '学员表现',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _studentPerformanceController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '请记录学员在本次课程中的表现...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '下次目标',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nextGoalController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '设定下次课程的目标...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('取消'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveCourseRecord,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('保存'),
          ),
        ),
      ],
    );
  }

  // 获取动作的组数
  int _getActionSetsCount(String actionId) {
    final action = _actionTrainings.firstWhere(
      (action) => action.id == actionId,
      orElse: () =>
          course_record.ActionTraining(id: '', category: '', sets: []),
    );
    return action.sets.length;
  }

  // 移除组数
  void _removeSetFromAction(String actionId, int setNumber) {
    setState(() {
      final actionIndex = _actionTrainings.indexWhere(
        (action) => action.id == actionId,
      );
      if (actionIndex != -1) {
        final action = _actionTrainings[actionIndex];
        final updatedSets = action.sets
            .where((set) => set.setNumber != setNumber)
            .map((set) {
              // 重新编号剩余的组数
              if (set.setNumber > setNumber) {
                return course_record.ExerciseSet(
                  setNumber: set.setNumber - 1,
                  weight: set.weight,
                  reps: set.reps,
                  duration: set.duration,
                  notes: set.notes,
                );
              }
              return set;
            })
            .toList();

        final updatedAction = course_record.ActionTraining(
          id: action.id,
          category: action.category,
          exerciseName: action.exerciseName,
          exerciseId: action.exerciseId,
          sets: updatedSets,
          notes: action.notes,
        );
        _actionTrainings[actionIndex] = updatedAction;
      }
    });
  }
}
