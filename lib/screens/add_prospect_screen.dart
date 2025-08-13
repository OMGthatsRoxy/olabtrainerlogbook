import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../services/data_service.dart';

class AddProspectScreen extends StatefulWidget {
  const AddProspectScreen({super.key});

  @override
  State<AddProspectScreen> createState() => _AddProspectScreenState();
}

class _AddProspectScreenState extends State<AddProspectScreen> {
  final _formKey = GlobalKey<FormState>();

  // 表单控制器
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  // 选择的值
  ProspectGender _selectedGender = ProspectGender.male;
  ProspectFitnessGoal _selectedFitnessGoal = ProspectFitnessGoal.general;
  ProspectSource _selectedSource = ProspectSource.online;

  bool _isLoading = false;

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
          '添加潜在客户',
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
            children: [
              // 潜在客户姓名
              _buildTextField(
                controller: _nameController,
                label: '潜在客户姓名*',
                hint: '请输入潜在客户姓名',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入潜在客户姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 电话
              _buildTextField(
                controller: _phoneController,
                label: '电话*',
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
                label: '邮箱*',
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
                items: ProspectGender.values.map((gender) {
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
                items: ProspectFitnessGoal.values.map((goal) {
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

              // 来源
              _buildDropdownField(
                label: '来源',
                hint: '请选择来源',
                value: _selectedSource,
                items: ProspectSource.values.map((source) {
                  return DropdownMenuItem(
                    value: source,
                    child: Text(_getSourceText(source)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSource = value!;
                  });
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

              // 添加潜在客户按钮
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
                          '添加潜在客户',
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

  String _getGenderText(ProspectGender gender) {
    switch (gender) {
      case ProspectGender.male:
        return '男';
      case ProspectGender.female:
        return '女';
      case ProspectGender.other:
        return '其他';
    }
  }

  String _getFitnessGoalText(ProspectFitnessGoal goal) {
    switch (goal) {
      case ProspectFitnessGoal.weightLoss:
        return '减脂';
      case ProspectFitnessGoal.muscleGain:
        return '增肌';
      case ProspectFitnessGoal.endurance:
        return '耐力';
      case ProspectFitnessGoal.flexibility:
        return '柔韧性';
      case ProspectFitnessGoal.strength:
        return '力量';
      case ProspectFitnessGoal.general:
        return '一般健身';
    }
  }

  String _getSourceText(ProspectSource source) {
    switch (source) {
      case ProspectSource.referral:
        return '推荐';
      case ProspectSource.online:
        return '线上';
      case ProspectSource.walkIn:
        return '上门';
      case ProspectSource.social:
        return '社交媒体';
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
      final prospect = Prospect(
        id: '', // Firebase会自动生成ID
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        gender: _selectedGender,
        age: int.tryParse(_ageController.text) ?? 0,
        height: double.tryParse(_heightController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0,
        fitnessGoal: _selectedFitnessGoal,
        source: _selectedSource,
        status: ProspectStatus.contacted,
        notes: _notesController.text,
        contactDate: DateTime.now(),
      );

      final dataService = Provider.of<DataService>(context, listen: false);
      final success = await dataService.addProspect(prospect);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('潜在客户添加成功'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('潜在客户添加失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加潜在客户时出错: $e'), backgroundColor: Colors.red),
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
