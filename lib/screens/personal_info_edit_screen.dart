import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/user_profile.dart';

class PersonalInfoEditScreen extends StatefulWidget {
  const PersonalInfoEditScreen({super.key});

  @override
  State<PersonalInfoEditScreen> createState() => _PersonalInfoEditScreenState();
}

class _PersonalInfoEditScreenState extends State<PersonalInfoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _introductionController = TextEditingController();
  final _certificatesController = TextEditingController();
  final _educationController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  
  bool _isPublicProfile = true;
  bool _isLoading = true;
  bool _isSaving = false;
  
  // 专长领域选项
  final Map<String, bool> _specialtyAreas = {
    '力量训练': false,
    '有氧运动': false,
    '瑜伽': false,
    '普拉提': false,
    '功能性训练': false,
    '康复训练': false,
    '其他': false,
  };

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _introductionController.dispose();
    _certificatesController.dispose();
    _educationController.dispose();
    _locationController.dispose();
    _experienceYearsController.dispose();
    super.dispose();
  }

  List<String> get _selectedSpecialties {
    return _specialtyAreas.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  void _toggleSpecialty(String specialty) {
    setState(() {
      _specialtyAreas[specialty] = !_specialtyAreas[specialty]!;
    });
  }

  void _removeSpecialty(String specialty) {
    setState(() {
      _specialtyAreas[specialty] = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final profile = await dataService.getUserProfile();
      
      if (mounted) {
        setState(() {
          if (profile != null) {
            _displayNameController.text = profile.displayName;
            _phoneController.text = profile.phone ?? '';
            _introductionController.text = profile.introduction ?? '';
            _certificatesController.text = profile.certificates ?? '';
            _educationController.text = profile.education ?? '';
            _locationController.text = profile.location ?? '';
            _experienceYearsController.text = profile.experienceYears.toString();
            _isPublicProfile = profile.isPublicProfile;
            
            // 设置专长领域
            for (String specialty in profile.specialties) {
              if (_specialtyAreas.containsKey(specialty)) {
                _specialtyAreas[specialty] = true;
              }
            }
          } else {
            // 如果没有现有数据，设置默认值
            _displayNameController.text = 'Oscar';
            _certificatesController.text = 'NASM';
            _locationController.text = 'KL';
            _experienceYearsController.text = '3';
            _isPublicProfile = true;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final currentUserId = dataService.currentUserId;
      
      if (currentUserId == null) {
        throw Exception('用户未登录');
      }
      
      final selectedSpecialties = _specialtyAreas.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      
      final profile = UserProfile(
        uid: currentUserId,
        displayName: _displayNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        introduction: _introductionController.text.trim().isEmpty ? null : _introductionController.text.trim(),
        specialties: selectedSpecialties,
        experienceYears: int.tryParse(_experienceYearsController.text) ?? 0,
        certificates: _certificatesController.text.trim().isEmpty ? null : _certificatesController.text.trim(),
        education: _educationController.text.trim().isEmpty ? null : _educationController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        isPublicProfile: _isPublicProfile,
        photoURL: null, // TODO: 实现头像上传
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await dataService.updateUserProfile(profile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存成功！'),
            backgroundColor: Colors.green,
          ),
        );
        // 等待一小段时间确保数据已保存，然后返回
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
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
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          '编辑个人信息',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 个人信息标题
              const Text(
                '个人信息',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // 头像上传
              Center(
                child: Column(
                  children: [
                    const Text(
                      '点击上传',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        // TODO: 实现头像上传功能
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF667eea),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF667eea),
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '点击上传',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 显示名称
              _buildTextField(
                controller: _displayNameController,
                label: '显示名称 *',
                hint: '显示名称',
              ),
              const SizedBox(height: 16),
              
              // 电话
              _buildTextField(
                controller: _phoneController,
                label: '电话',
                hint: '电话',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              // 个人简介
              _buildTextField(
                controller: _introductionController,
                label: '个人简介',
                hint: '介绍自己的专业背景和教学理念',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              
              // 专长领域
              const Text(
                '专长领域',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // 专长领域复选框
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: _specialtyAreas.entries.map((entry) {
                  return FilterChip(
                    label: Text(
                      entry.key,
                      style: TextStyle(
                        color: entry.value ? Colors.white : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    selected: entry.value,
                    onSelected: (_) => _toggleSpecialty(entry.key),
                    backgroundColor: const Color(0xFF2A2A2A),
                    selectedColor: const Color(0xFF667eea),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: entry.value 
                          ? const Color(0xFF667eea) 
                          : Colors.grey,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // 已选择的专长标签
              if (_selectedSpecialties.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedSpecialties.map((specialty) {
                    return Chip(
                      label: Text(
                        specialty,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: const Color(0xFF667eea),
                      deleteIcon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                      onDeleted: () => _removeSpecialty(specialty),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              // 经验年数
              _buildTextField(
                controller: _experienceYearsController,
                label: '经验年数',
                hint: '经验年数',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // 证书
              _buildTextField(
                controller: _certificatesController,
                label: '证书',
                hint: '证书',
              ),
              const SizedBox(height: 16),
              
              // 教育背景
              _buildTextField(
                controller: _educationController,
                label: '教育背景',
                hint: '教育背景',
              ),
              const SizedBox(height: 16),
              
              // 地点
              _buildTextField(
                controller: _locationController,
                label: '地点',
                hint: '地点',
              ),
              const SizedBox(height: 24),
              
              // 隐私设置
              Row(
                children: [
                  Checkbox(
                    value: _isPublicProfile,
                    onChanged: (value) {
                      setState(() {
                        _isPublicProfile = value ?? true;
                      });
                    },
                    activeColor: const Color(0xFF667eea),
                  ),
                  const Text(
                    '公开显示个人资料',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
                                      // 保存和取消按钮
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667eea),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                                    : const Text(
                                        '保存',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A2A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '取消',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
