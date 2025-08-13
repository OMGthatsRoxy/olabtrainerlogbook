import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import '../models/package.dart';
import '../services/data_service.dart';
import 'add_package_screen.dart';
import 'edit_client_screen.dart';
import 'course_complete_record_screen.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  late Client _currentClient;

  @override
  void initState() {
    super.initState();
    _currentClient = widget.client;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(
          _currentClient.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: StreamBuilder<List<Package>>(
        stream: Provider.of<DataService>(
          context,
          listen: false,
        ).streamPackages(clientId: _currentClient.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '加载配套数据失败: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final packages = snapshot.data ?? [];
          final activePackages = packages
              .where((package) => package.status == PackageStatus.active)
              .toList();
          final completedPackages = packages
              .where((package) => package.status == PackageStatus.completed)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 操作按钮区域
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      // 编辑按钮
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditClientScreen(client: _currentClient),
                              ),
                            );

                            // 如果编辑成功，更新客户信息
                            if (result != null && result is Client) {
                              setState(() {
                                _currentClient = result;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('编辑', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 课程完整记录按钮
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseCompleteRecordScreen(client: _currentClient),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('课程完整记录', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 添加配套按钮
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPackageScreen(
                                  clientId: _currentClient.id,
                                  clientName: _currentClient.name,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('添加配套', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),

                // 个人信息卡片
                _buildPersonalInfoCard(),
                const SizedBox(height: 20),

                // 有效配套卡片
                _buildActivePackagesCard(activePackages, packages),
                const SizedBox(height: 20),

                // 已完成配套卡片
                _buildCompletedPackagesCard(completedPackages, packages),
              ],
            ),
          );
        },
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
              _buildInfoItem('客户姓名', _currentClient.name),
              _buildInfoItem('电话', _currentClient.phone),
              _buildInfoItem('邮箱', _currentClient.email),
              _buildInfoItem('性别', _getGenderText(_currentClient.gender)),
              _buildInfoItem('年龄', '${_currentClient.age}'),
              _buildInfoItem('身高(cm)', '${_currentClient.height}'),
              _buildInfoItem('体重(kg)', '${_currentClient.weight}'),
              _buildInfoItem(
                '健身目标',
                _getFitnessGoalText(_currentClient.fitnessGoal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivePackagesCard(
    List<Package> activePackages,
    List<Package> allPackages,
  ) {
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
          Text(
            '有效配套(${activePackages.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if (activePackages.isEmpty)
            const Center(
              child: Text(
                '暂无有效配套',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          else
            ...activePackages.map(
              (package) => _buildPackageItem(package, allPackages),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedPackagesCard(
    List<Package> completedPackages,
    List<Package> allPackages,
  ) {
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
          Text(
            '已完成配套(${completedPackages.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if (completedPackages.isEmpty)
            const Center(
              child: Text(
                '暂无已完成配套',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          else
            ...completedPackages.map(
              (package) => _buildPackageItem(package, allPackages),
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

  Widget _buildPackageItem(Package package, List<Package> allPackages) {
    // 检查是否是第一个配套（创建时间最早的）
    final isFirstPackage = package == allPackages.last;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirstPackage
              ? const Color(0xFF667eea).withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: isFirstPackage ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 配套标题
          Row(
            children: [
              if (isFirstPackage)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '首次配套',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isFirstPackage) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '配套',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPackageInfoRow('总课时', '${package.totalHours}'),
                    _buildPackageInfoRow(
                      '总金额',
                      '¥${package.totalAmount.toStringAsFixed(2)}',
                    ),
                    _buildPackageInfoRow(
                      '剩余次数',
                      '${package.remainingSessions}',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPackageInfoRow(
                      '开始日期',
                      _formatDate(package.startDate),
                    ),
                    _buildPackageInfoRow(
                      '过期日期',
                      _formatDate(package.expiryDate),
                    ),
                    _buildPackageInfoRow(
                      '状态',
                      _getPackageStatusText(package.status),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (package.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPackageInfoRow('备注', package.notes),
          ],
          if (package.status == PackageStatus.active) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _deletePackage(package),
                  child: const Text(
                    '删除',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
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

  String _getPackageStatusText(PackageStatus status) {
    switch (status) {
      case PackageStatus.active:
        return '有效';
      case PackageStatus.completed:
        return '已完成';
      case PackageStatus.expired:
        return '已过期';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _deletePackage(Package package) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '确认删除',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '确定要删除这个配套吗？此操作不可撤销。',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        final success = await dataService.deletePackage(package.id);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('配套删除成功'),
                backgroundColor: Colors.green,
              ),
            );
            // 不需要手动刷新，StreamBuilder会自动更新
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('配套删除失败'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除配套时出错: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
