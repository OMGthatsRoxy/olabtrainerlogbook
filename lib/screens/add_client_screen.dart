import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import '../models/package.dart';
import '../services/data_service.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();

  // 表单控制器
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _courseCountController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _notesController = TextEditingController();

  // 选择的值
  ClientGender _selectedGender = ClientGender.male;
  FitnessGoal _selectedFitnessGoal = FitnessGoal.general;
  DateTime _startDate = DateTime.now();
  DateTime _expiryDate = DateTime.now();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _courseCountController.dispose();
    _totalAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          '添加客户及配套',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明文字
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '添加新客户',
                      style: TextStyle(
                        color: Color(0xFF667eea),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '客户信息和首次购买的配套信息',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 客户姓名
              _buildTextField(
                controller: _nameController,
                label: '客户姓名',
                hint: '客户姓名',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入客户姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 电话
              _buildTextField(
                controller: _phoneController,
                label: '电话',
                hint: '电话',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入电话号码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 邮箱
              _buildTextField(
                controller: _emailController,
                label: '邮箱',
                hint: '邮箱',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入邮箱地址';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 性别
              _buildDropdownField(
                label: '性别',
                hint: '请选择性别',
                value: _selectedGender,
                items: ClientGender.values.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(_getGenderText(gender)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 年龄
              _buildTextField(
                controller: _ageController,
                label: '年龄',
                hint: '请选择年龄',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入年龄';
                  }
                  if (int.tryParse(value) == null) {
                    return '请输入有效的年龄';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 身高
              _buildTextField(
                controller: _heightController,
                label: '身高(cm)',
                hint: '请选择身高',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入身高';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效的身高';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 体重
              _buildTextField(
                controller: _weightController,
                label: '体重(kg)',
                hint: '请选择体重',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入体重';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效的体重';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 健身目标
              _buildDropdownField(
                label: '健身目标',
                hint: '请选择健身目标',
                value: _selectedFitnessGoal,
                items: FitnessGoal.values.map((goal) {
                  return DropdownMenuItem(
                    value: goal,
                    child: Text(_getFitnessGoalText(goal)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFitnessGoal = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 课程数量
              _buildTextField(
                controller: _courseCountController,
                label: '配套课时数',
                hint: '请输入课时数',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入课时数';
                  }
                  if (int.tryParse(value) == null) {
                    return '请输入有效的课时数';
                  }
                  if (int.parse(value) <= 0) {
                    return '课时数必须大于0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 总金额
              _buildTextField(
                controller: _totalAmountController,
                label: '配套总金额',
                hint: '请输入总金额',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入总金额';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效的金额';
                  }
                  if (double.parse(value) <= 0) {
                    return '金额必须大于0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 开始日期
              _buildDateField(
                label: '配套开始日期',
                value: _startDate ?? DateTime.now(),
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 16),

              // 结束日期
              _buildDateField(
                label: '配套结束日期',
                value:
                    _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),

              // 备注
              _buildTextField(
                controller: _notesController,
                label: '备注',
                hint: '备注',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          '添加客户及配套',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required dynamic value,
    required List<DropdownMenuItem> items,
    required Function(dynamic) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField(
            value: value,
            items: items,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white),
            dropdownColor: const Color(0xFF2A2A2A),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF667eea),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _expiryDate,
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
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  String _getGenderText(ClientGender gender) {
    switch (gender) {
      case ClientGender.male:
        return '男';
      case ClientGender.female:
        return '女';
      case ClientGender.other:
        return '其他';
    }
  }

  String _getFitnessGoalText(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.weightLoss:
        return '减脂';
      case FitnessGoal.muscleGain:
        return '增肌';
      case FitnessGoal.endurance:
        return '耐力';
      case FitnessGoal.flexibility:
        return '柔韧性';
      case FitnessGoal.strength:
        return '力量';
      case FitnessGoal.general:
        return '一般健身';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dataService = Provider.of<DataService>(context, listen: false);

      // 创建客户对象
      final client = Client(
        id: '', // Firebase会自动生成ID
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender ?? ClientGender.other,
        age: int.tryParse(_ageController.text) ?? 0,
        height: double.tryParse(_heightController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0,
        fitnessGoal: _selectedFitnessGoal ?? FitnessGoal.general,
        courseCount: int.tryParse(_courseCountController.text) ?? 0,
        totalAmount: double.tryParse(_totalAmountController.text) ?? 0,
        startDate: _startDate ?? DateTime.now(),
        expiryDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
        joinDate: DateTime.now(),
        status: ClientStatus.active,
        notes: _notesController.text.trim(),
      );

      // 添加客户
      final clientSuccess = await dataService.addClient(client);

      if (clientSuccess) {
        // 获取刚创建的客户ID
        final clients = await dataService.getClients();
        final newClient = clients.firstWhere(
          (c) => c.name == client.name && c.phone == client.phone,
          orElse: () => client,
        );

        // 创建第一个配套
        final package = Package(
          id: '', // Firebase会自动生成ID
          clientId: newClient.id,
          totalHours: int.tryParse(_courseCountController.text) ?? 0,
          totalAmount: double.tryParse(_totalAmountController.text) ?? 0,
          remainingSessions: int.tryParse(_courseCountController.text) ?? 0,
          startDate: _startDate ?? DateTime.now(),
          expiryDate:
              _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
          status: PackageStatus.active,
          notes: '客户首次购买的配套',
          createdAt: DateTime.now(),
        );

        // 添加配套
        final packageSuccess = await dataService.addPackage(package);

        if (mounted) {
          if (packageSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('客户和配套添加成功'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('客户添加成功，但配套添加失败'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('添加客户失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加客户时出错: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
