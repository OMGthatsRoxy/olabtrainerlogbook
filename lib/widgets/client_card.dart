import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import '../models/prospect.dart';
import '../models/package.dart';
import '../services/data_service.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;

  const ClientCard({super.key, required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF667eea),
                    child: Text(
                      client.name.isNotEmpty ? client.name[0] : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                client.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: client.status == ClientStatus.active
                                    ? Colors.green[100]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                client.status == ClientStatus.active
                                    ? '活跃'
                                    : '非活跃',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: client.status == ClientStatus.active
                                      ? Colors.green[700]
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client.phone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '加入时间: ${_formatDate(client.joinDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          // 删除按钮
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _showDeleteDialog(context),
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '确认删除',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '确定要将客户"${client.name}"移动至潜在客户吗？\n\n此操作将：\n• 将客户信息移动至潜在客户列表\n• 将该客户的所有配套标记为已完成\n• 此操作不可撤销',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteClient(context);
            },
            child: const Text('确认删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClient(BuildContext context) async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);

      // 1. 创建潜在客户对象
      final prospect = Prospect(
        id: '', // Firebase会自动生成ID
        name: client.name,
        phone: client.phone,
        email: client.email,
        gender: _convertGender(client.gender),
        age: client.age,
        height: client.height,
        weight: client.weight,
        fitnessGoal: _convertFitnessGoal(client.fitnessGoal),
        source: ProspectSource.referral, // 默认来源
        status: ProspectStatus.converted, // 标记为已转化
        contactDate: DateTime.now(),
        notes: '从客户列表移动：${client.notes}',
      );

      // 2. 添加潜在客户
      final prospectSuccess = await dataService.addProspect(prospect);

      if (prospectSuccess) {
        // 3. 获取该客户的所有配套并标记为已完成
        final packages = await dataService.getPackages(clientId: client.id);

        for (final package in packages) {
          if (package.status == PackageStatus.active) {
            final updatedPackage = package.copyWith(
              status: PackageStatus.completed,
            );
            await dataService.updatePackage(updatedPackage);
          }
        }

        // 4. 删除客户
        final deleteSuccess = await dataService.deleteClient(client.id);

        if (context.mounted) {
          if (deleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('客户"${client.name}"已移动至潜在客户'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('客户移动失败'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('创建潜在客户失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除客户时出错: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  ProspectGender _convertGender(ClientGender gender) {
    switch (gender) {
      case ClientGender.male:
        return ProspectGender.male;
      case ClientGender.female:
        return ProspectGender.female;
      case ClientGender.other:
        return ProspectGender.other;
    }
  }

  ProspectFitnessGoal _convertFitnessGoal(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.weightLoss:
        return ProspectFitnessGoal.weightLoss;
      case FitnessGoal.muscleGain:
        return ProspectFitnessGoal.muscleGain;
      case FitnessGoal.endurance:
        return ProspectFitnessGoal.endurance;
      case FitnessGoal.flexibility:
        return ProspectFitnessGoal.flexibility;
      case FitnessGoal.strength:
        return ProspectFitnessGoal.strength;
      case FitnessGoal.general:
        return ProspectFitnessGoal.general;
    }
  }
}
