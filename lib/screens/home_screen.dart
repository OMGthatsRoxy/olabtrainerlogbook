import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../models/package.dart';
import '../models/schedule.dart';
import '../models/user_profile.dart';
import '../models/client.dart';
import '../models/prospect.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  UserProfile? _userProfile;
  Map<String, dynamic> _monthlyStats = {};
  Map<String, dynamic> _careerStats = {};

  @override
  void initState() {
    super.initState();
    _setupUserProfileListener();
    _loadStats();
  }

  void _setupUserProfileListener() {
    final dataService = Provider.of<DataService>(context, listen: false);
    dataService.streamUserProfile().listen(
      (profile) {
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _userName = profile?.displayName ?? 'User';
          });
        }
      },
      onError: (error) {
        // 如果监听失败，使用邮箱
        final authService = Provider.of<AuthService>(context, listen: false);
        final userEmail = authService.currentUser?.email;
        if (userEmail != null && mounted) {
          setState(() {
            _userName = userEmail.split('@')[0];
          });
        }
      },
    );
  }

  Future<void> _loadUserInfo() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);

    // 首先尝试获取用户资料
    try {
      final profile = await dataService.getUserProfile();
      if (profile != null && profile.displayName.isNotEmpty) {
        setState(() {
          _userProfile = profile;
          _userName = profile.displayName;
        });
        return;
      }
    } catch (e) {
      // 忽略错误，继续使用邮箱
    }

    // 如果没有用户资料或显示名称为空，使用邮箱
    final userEmail = authService.currentUser?.email;
    if (userEmail != null) {
      setState(() {
        _userName = userEmail.split('@')[0]; // 使用邮箱前缀作为用户名
      });
    }
  }

  Future<void> _loadStats() async {
    final dataService = Provider.of<DataService>(context, listen: false);

    try {
      // 获取所有数据
      final clients = await dataService.getClients();
      final packages = await dataService.getPackages();
      final schedules = await dataService.getSchedules();
      final prospects = await dataService.getProspects();

      // 计算本月数据
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      // 本月新增配套
      final monthlyPackages = packages
          .where(
            (p) =>
                p.createdAt.isAfter(startOfMonth) &&
                p.createdAt.isBefore(endOfMonth),
          )
          .toList();

      // 本月已完成课程
      final monthlyCompletedSchedules = schedules
          .where(
            (s) =>
                s.date.isAfter(startOfMonth) &&
                s.date.isBefore(endOfMonth) &&
                s.status == ScheduleStatus.confirmed,
          )
          .toList();

      // 今日课程
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final todaySchedules = schedules
          .where((s) => s.date.isAfter(today) && s.date.isBefore(tomorrow))
          .toList();

      // 本月活跃客户（本月有预约上课的客户）
      final monthlyActiveClientIds = monthlyCompletedSchedules
          .map((s) => s.clientId)
          .toSet(); // 去重
      final monthlyActiveClients = clients
          .where((c) => monthlyActiveClientIds.contains(c.id))
          .toList();

      // 剩余客户配套
      final remainingPackages = packages
          .where(
            (p) => p.status == PackageStatus.active && p.remainingSessions > 0,
          )
          .toList();

      // 计算收入（模拟数据）
      final monthlyIncome = monthlyPackages.fold<double>(
        0,
        (sum, p) => sum + p.totalAmount,
      );
      final totalIncome = packages.fold<double>(
        0,
        (sum, p) => sum + p.totalAmount,
      );

      // 生涯执教时长（模拟数据）
      final careerHours = schedules
          .where((s) => s.status == ScheduleStatus.confirmed)
          .length;

      setState(() {
        _monthlyStats = {
          'income': monthlyIncome,
          'todayCourses': todaySchedules.length,
          'completedCourses': monthlyCompletedSchedules.length,
          'newPackages': monthlyPackages.length,
          'activeClients': monthlyActiveClients.length,
        };

        _careerStats = {
          'totalIncome': totalIncome,
          'totalClients': clients.length,
          'remainingPackages': remainingPackages.length,
          'potentialClients': prospects.length,
          'careerHours': careerHours,
        };
      });
    } catch (e) {
      // 忽略错误
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20), // 增加顶部间距
              // 标题
              const Text(
                '健身教练客户管理 与 排课系统',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '高效管理客户、配套与课程,助力教练提升服务',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 欢迎栏
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF667eea),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _userName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '欢迎, ${_userName ?? 'User'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 实时统计数据
              StreamBuilder<List<Package>>(
                stream: Provider.of<DataService>(
                  context,
                  listen: false,
                ).streamPackages(),
                builder: (context, packagesSnapshot) {
                  return StreamBuilder<List<Schedule>>(
                    stream: Provider.of<DataService>(
                      context,
                      listen: false,
                    ).streamSchedules(),
                    builder: (context, schedulesSnapshot) {
                      return StreamBuilder<List<Client>>(
                        stream: Provider.of<DataService>(
                          context,
                          listen: false,
                        ).streamClients(),
                        builder: (context, clientsSnapshot) {
                          return StreamBuilder<List<Prospect>>(
                            stream: Provider.of<DataService>(
                              context,
                              listen: false,
                            ).streamProspects(),
                            builder: (context, prospectsSnapshot) {
                              // 计算实时统计数据
                              final packages = packagesSnapshot.data ?? [];
                              final schedules = schedulesSnapshot.data ?? [];
                              final clients = clientsSnapshot.data ?? [];
                              final prospects = prospectsSnapshot.data ?? [];

                              // 计算本月数据
                              final now = DateTime.now();
                              final startOfMonth = DateTime(
                                now.year,
                                now.month,
                                1,
                              );
                              final endOfMonth = DateTime(
                                now.year,
                                now.month + 1,
                                0,
                              );

                              // 本月新增配套
                              final monthlyPackages = packages
                                  .where(
                                    (p) =>
                                        p.createdAt.isAfter(startOfMonth) &&
                                        p.createdAt.isBefore(endOfMonth),
                                  )
                                  .toList();

                              // 本月已完成课程
                              final monthlyCompletedSchedules = schedules
                                  .where(
                                    (s) =>
                                        s.date.isAfter(startOfMonth) &&
                                        s.date.isBefore(endOfMonth) &&
                                        s.status == ScheduleStatus.completed,
                                  )
                                  .toList();

                              // 今日课程
                              final today = DateTime(
                                now.year,
                                now.month,
                                now.day,
                              );
                              final tomorrow = today.add(
                                const Duration(days: 1),
                              );
                              final todaySchedules = schedules
                                  .where(
                                    (s) =>
                                        s.date.isAfter(today) &&
                                        s.date.isBefore(tomorrow),
                                  )
                                  .toList();

                              // 本月活跃客户（本月有预约上课的客户）
                              final monthlyActiveClientIds =
                                  monthlyCompletedSchedules
                                      .map((s) => s.clientId)
                                      .toSet(); // 去重
                              final monthlyActiveClients = clients
                                  .where(
                                    (c) =>
                                        monthlyActiveClientIds.contains(c.id),
                                  )
                                  .toList();

                              // 剩余客户配套
                              final remainingPackages = packages
                                  .where(
                                    (p) =>
                                        p.status == PackageStatus.active &&
                                        p.remainingSessions > 0,
                                  )
                                  .toList();

                              // 计算收入
                              final monthlyIncome = monthlyPackages
                                  .fold<double>(
                                    0,
                                    (sum, p) => sum + p.totalAmount,
                                  );
                              final totalIncome = packages.fold<double>(
                                0,
                                (sum, p) => sum + p.totalAmount,
                              );

                              // 生涯执教时长
                              final careerHours = schedules
                                  .where(
                                    (s) => s.status == ScheduleStatus.completed,
                                  )
                                  .length;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 本月成绩
                                  const Text(
                                    '本月成绩',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 本月进账
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '¥${monthlyIncome.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          '本月进账',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 统计卡片网格
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          '今日课程',
                                          '${todaySchedules.length}',
                                          Icons.calendar_today,
                                          Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          '本月完成',
                                          '${monthlyCompletedSchedules.length}',
                                          Icons.check_circle,
                                          Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          '新增配套',
                                          '${monthlyPackages.length}',
                                          Icons.add_box,
                                          Colors.orange,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          '活跃客户',
                                          '${monthlyActiveClients.length}',
                                          Icons.people,
                                          Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  // 生涯数据
                                  const Text(
                                    '生涯数据',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 生涯数据网格
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          '总收入',
                                          '¥${totalIncome.toStringAsFixed(2)}',
                                          Icons.attach_money,
                                          Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          '总客户',
                                          '${clients.length}',
                                          Icons.people,
                                          Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          '剩余配套',
                                          '${remainingPackages.length}',
                                          Icons.inventory,
                                          Colors.orange,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          '潜在客户',
                                          '${prospects.length}',
                                          Icons.person_add,
                                          Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          '执教时长',
                                          '${careerHours}h',
                                          Icons.fitness_center,
                                          Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(child: SizedBox()),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
