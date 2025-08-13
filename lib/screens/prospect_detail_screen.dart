import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prospect.dart';
import '../models/client.dart';
import '../models/package.dart';
import '../services/data_service.dart';

class ProspectDetailScreen extends StatefulWidget {
  final Prospect prospect;

  const ProspectDetailScreen({super.key, required this.prospect});

  @override
  State<ProspectDetailScreen> createState() => _ProspectDetailScreenState();
}

class _ProspectDetailScreenState extends State<ProspectDetailScreen> {
  bool _isConverting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(
          widget.prospect.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        actions: [
          // 转换为客户按钮
          ElevatedButton(
            onPressed: _isConverting ? null : _convertToClient,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: _isConverting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('转为客户', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 个人信息卡片
            _buildPersonalInfoCard(),
            const SizedBox(height: 20),

            // 联系信息卡片
            _buildContactInfoCard(),
            const SizedBox(height: 20),

            // 健身信息卡片
            _buildFitnessInfoCard(),
            const SizedBox(height: 20),

            // 备注卡片
            if (widget.prospect.notes.isNotEmpty) ...[
              _buildNotesCard(),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '个人信息',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 个人信息网格
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3,
            children: [
              _buildInfoItem('姓名', widget.prospect.name),
              _buildInfoItem('性别', _getGenderText(widget.prospect.gender)),
              _buildInfoItem('年龄', '${widget.prospect.age}'),
              _buildInfoItem('身高(cm)', '${widget.prospect.height}'),
              _buildInfoItem('体重(kg)', '${widget.prospect.weight}'),
              _buildInfoItem(
                '健身目标',
                _getFitnessGoalText(widget.prospect.fitnessGoal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '联系信息',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildInfoRow('电话', widget.prospect.phone),
          const SizedBox(height: 12),
          _buildInfoRow('邮箱', widget.prospect.email),
          const SizedBox(height: 12),
          _buildInfoRow('来源', _getSourceText(widget.prospect.source)),
          const SizedBox(height: 12),
          _buildInfoRow('状态', _getStatusText(widget.prospect.status)),
          const SizedBox(height: 12),
          _buildInfoRow('联系时间', _formatDate(widget.prospect.contactDate)),
        ],
      ),
    );
  }

  Widget _buildFitnessInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '健身信息',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildInfoRow(
            '健身目标',
            _getFitnessGoalText(widget.prospect.fitnessGoal),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('身高', '${widget.prospect.height} cm'),
          const SizedBox(height: 12),
          _buildInfoRow('体重', '${widget.prospect.weight} kg'),
          const SizedBox(height: 12),
          _buildInfoRow('BMI', _calculateBMI()),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '备注',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.prospect.notes,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
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

  String _getStatusText(ProspectStatus status) {
    switch (status) {
      case ProspectStatus.contacted:
        return '已联系';
      case ProspectStatus.interested:
        return '感兴趣';
      case ProspectStatus.notInterested:
        return '不感兴趣';
      case ProspectStatus.converted:
        return '已转化';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _calculateBMI() {
    if (widget.prospect.height > 0) {
      final heightInMeters = widget.prospect.height / 100;
      final bmi = widget.prospect.weight / (heightInMeters * heightInMeters);
      return bmi.toStringAsFixed(1);
    }
    return 'N/A';
  }

  Future<void> _convertToClient() async {
    setState(() {
      _isConverting = true;
    });

    try {
      final dataService = Provider.of<DataService>(context, listen: false);

      // 创建客户对象
      final client = Client(
        id: '', // Firebase会自动生成ID
        name: widget.prospect.name,
        phone: widget.prospect.phone,
        email: widget.prospect.email,
        gender: _convertGender(widget.prospect.gender),
        age: widget.prospect.age,
        height: widget.prospect.height,
        weight: widget.prospect.weight,
        fitnessGoal: _convertFitnessGoal(widget.prospect.fitnessGoal),
        courseCount: 0, // 初始为0，需要购买配套
        totalAmount: 0, // 初始为0
        startDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        joinDate: DateTime.now(),
        status: ClientStatus.active,
        notes: '从潜在客户转化：${widget.prospect.notes}',
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

        // 删除潜在客户
        final deleteSuccess = await dataService.deleteProspect(
          widget.prospect.id,
        );

        if (mounted) {
          if (deleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('成功转换为客户'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // 返回true表示转换成功
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('客户创建成功，但删除潜在客户记录失败'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.of(context).pop(true);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('转换为客户失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('转换过程中出错: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConverting = false;
        });
      }
    }
  }

  ClientGender _convertGender(ProspectGender gender) {
    switch (gender) {
      case ProspectGender.male:
        return ClientGender.male;
      case ProspectGender.female:
        return ClientGender.female;
      case ProspectGender.other:
        return ClientGender.other;
    }
  }

  FitnessGoal _convertFitnessGoal(ProspectFitnessGoal goal) {
    switch (goal) {
      case ProspectFitnessGoal.weightLoss:
        return FitnessGoal.weightLoss;
      case ProspectFitnessGoal.muscleGain:
        return FitnessGoal.muscleGain;
      case ProspectFitnessGoal.endurance:
        return FitnessGoal.endurance;
      case ProspectFitnessGoal.flexibility:
        return FitnessGoal.flexibility;
      case ProspectFitnessGoal.strength:
        return FitnessGoal.strength;
      case ProspectFitnessGoal.general:
        return FitnessGoal.general;
    }
  }
}

