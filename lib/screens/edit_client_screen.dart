import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import '../services/data_service.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();

  // 表单控制器
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  // 下拉选择状态
  ClientGender? _selectedGender;
  FitnessGoal? _selectedFitnessGoal;
  ClientStatus? _selectedStatus;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.client.name;
    _phoneController.text = widget.client.phone;
    _emailController.text = widget.client.email;
    _ageController.text = widget.client.age.toString();
    _heightController.text = widget.client.height.toString();
    _weightController.text = widget.client.weight.toString();
    _notesController.text = widget.client.notes;

    _selectedGender = widget.client.gender;
    _selectedFitnessGoal = widget.client.fitnessGoal;
    _selectedStatus = widget.client.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          '编辑客户信息',
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
                      '编辑客户信息',
                      style: TextStyle(
                        color: Color(0xFF667eea),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '修改客户的基本信息和健身目标',
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
                hint: '请输入客户姓名',
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
                hint: '请输入电话号码',
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
                hint: '请输入邮箱地址',
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
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return '请选择性别';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 年龄
              _buildTextField(
                controller: _ageController,
                label: '年龄',
                hint: '请输入年龄',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null) {
                      return '请输入有效的年龄';
                    }
                    if (age < 1 || age > 120) {
                      return '年龄必须在1-120之间';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 身高
              _buildTextField(
                controller: _heightController,
                label: '身高(cm)',
                hint: '请输入身高',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final height = double.tryParse(value);
                    if (height == null) {
                      return '请输入有效的身高';
                    }
                    if (height < 100 || height > 250) {
                      return '身高必须在100-250cm之间';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 体重
              _buildTextField(
                controller: _weightController,
                label: '体重(kg)',
                hint: '请输入体重',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final weight = double.tryParse(value);
                    if (weight == null) {
                      return '请输入有效的体重';
                    }
                    if (weight < 20 || weight > 200) {
                      return '体重必须在20-200kg之间';
                    }
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
                    _selectedFitnessGoal = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return '请选择健身目标';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 客户状态
              _buildDropdownField(
                label: '客户状态',
                hint: '请选择客户状态',
                value: _selectedStatus,
                items: ClientStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return '请选择客户状态';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 备注
              _buildTextField(
                controller: _notesController,
                label: '备注',
                hint: '请输入备注信息',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // 保存按钮
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
                          '保存修改',
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
    String? Function(dynamic)? validator,
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
        DropdownButtonFormField(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF2A2A2A),
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

  String _getStatusText(ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
        return '活跃';
      case ClientStatus.inactive:
        return '非活跃';
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
      // 创建更新后的客户对象
      final updatedClient = Client(
        id: widget.client.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender ?? ClientGender.other,
        age: int.tryParse(_ageController.text) ?? 0,
        height: double.tryParse(_heightController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0,
        fitnessGoal: _selectedFitnessGoal ?? FitnessGoal.general,
        courseCount: widget.client.courseCount, // 保持不变
        totalAmount: widget.client.totalAmount, // 保持不变
        startDate: widget.client.startDate, // 保持不变
        expiryDate: widget.client.expiryDate, // 保持不变
        joinDate: widget.client.joinDate, // 保持不变
        status: _selectedStatus ?? ClientStatus.active,
        notes: _notesController.text.trim(),
        avatar: widget.client.avatar, // 保持不变
      );

      final dataService = Provider.of<DataService>(context, listen: false);
      final success = await dataService.updateClient(updatedClient);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('客户信息更新成功'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(updatedClient); // 返回更新后的客户对象
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('客户信息更新失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新客户信息时出错: $e'), backgroundColor: Colors.red),
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

