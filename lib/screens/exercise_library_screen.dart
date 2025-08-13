import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/exercise.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 身体部位分类
  final Map<String, Color> _categories = {
    '胸': Colors.red,
    '背': Colors.orange,
    '肩膀': Colors.green,
    '手臂': Colors.blue,
    '臀': Colors.purple,
    '腿': Colors.brown,
    '全身': Colors.cyan,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20), // 增加顶部间距
            // 标题
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Text(
                '动作库',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // 身体部位分类
            if (_selectedCategory == null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择动作分类',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _categories.entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _selectCategory(entry.key),
                          child: Container(
                            width: 100,
                            height: 60,
                            decoration: BoxDecoration(
                              color: entry.value.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: entry.value, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  color: entry.value,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 动作列表页面
              Expanded(child: _buildExerciseList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    return Column(
      children: [
        // 头部控制栏
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 标题和返回按钮
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      '$_selectedCategory 动作',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddExerciseDialog();
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('添加动作'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 搜索框
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '搜索动作...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.clear, color: Colors.grey),
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF667eea),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 动作列表
        Expanded(
          child: StreamBuilder<List<Exercise>>(
            stream: Provider.of<DataService>(
              context,
              listen: false,
            ).streamExercises(bodyPart: _selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF667eea),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '加载失败: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              List<Exercise> exercises = snapshot.data ?? [];

              // 过滤搜索结果
              if (_searchQuery.isNotEmpty) {
                exercises = exercises
                    .where(
                      (exercise) => exercise.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();
              }

              // 在内存中排序
              exercises.sort((a, b) => a.name.compareTo(b.name));

              if (exercises.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty ? '没有找到匹配的动作' : '还没有添加动作',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      if (_searchQuery.isEmpty) ...[
                        ElevatedButton(
                          onPressed: () => _showAddExerciseDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('添加第一个动作'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showAllExercises(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('查看所有动作（调试）'),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        exercise.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: exercise.description.isNotEmpty
                          ? Text(
                              exercise.description,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: IconButton(
                        onPressed: () => _deleteExercise(exercise),
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                      onTap: () => _showExerciseDetails(exercise),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddExerciseDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final instructionsController = TextEditingController();
    final equipmentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('添加动作', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: '动作名称 *',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF667eea)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '描述',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF667eea)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: instructionsController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '动作要领',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF667eea)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: equipmentController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: '所需器械',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF667eea)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final dataService = Provider.of<DataService>(
                  context,
                  listen: false,
                );

                final exercise = Exercise(
                  id: '',
                  name: nameController.text.trim(),
                  bodyPart: _selectedCategory!,
                  description: descriptionController.text.trim().isEmpty
                      ? ''
                      : descriptionController.text.trim(),
                  difficulty: '初级',
                  equipment: equipmentController.text.trim().isEmpty
                      ? '无器械'
                      : equipmentController.text.trim(),
                  muscleGroups: [],
                  instructions: instructionsController.text.trim().isEmpty
                      ? []
                      : [instructionsController.text.trim()],
                  userId: dataService.currentUserId ?? '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await dataService.addExercise(exercise);

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('动作添加成功！'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showExerciseDetails(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(exercise.name, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...[
                const Text(
                  '描述:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.description.isNotEmpty
                      ? exercise.description
                      : '暂无描述',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
              ],
              ...[
                const Text(
                  '动作要领:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.instructions.isNotEmpty
                      ? exercise.instructions.join('\n')
                      : '暂无',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
              ],
              ...[
                const Text(
                  '所需器械:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.equipment.isNotEmpty ? exercise.equipment : '无器械',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showAllExercises() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final allExercises = await dataService.getAllExercises();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('所有动作（调试）', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '总数量: ${allExercises.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...allExercises
                    .map(
                      (exercise) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '名称: ${exercise.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '身体部位: ${exercise.bodyPart}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              '用户ID: ${exercise.userId}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _deleteExercise(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('删除动作', style: TextStyle(color: Colors.white)),
        content: Text(
          '确定要删除动作"${exercise.name}"吗？',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final dataService = Provider.of<DataService>(
                context,
                listen: false,
              );
              await dataService.deleteExercise(exercise.id);

              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('动作删除成功！'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
