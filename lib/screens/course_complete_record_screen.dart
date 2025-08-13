import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_record.dart' as course_record;
import '../models/client.dart';
import '../services/data_service.dart';
import 'course_record_detail_screen.dart';

class CourseCompleteRecordScreen extends StatefulWidget {
  final Client client;

  const CourseCompleteRecordScreen({super.key, required this.client});

  @override
  State<CourseCompleteRecordScreen> createState() =>
      _CourseCompleteRecordScreenState();
}

class _CourseCompleteRecordScreenState
    extends State<CourseCompleteRecordScreen> {
  List<course_record.CourseRecord> _courseRecords = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourseRecords();
  }

  Future<void> _loadCourseRecords() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final records = await dataService.getCourseRecordsByClient(
        widget.client.id,
      );

      if (mounted) {
        setState(() {
          _courseRecords = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载课程记录失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _getTrainingModeText(course_record.TrainingMode? mode) {
    if (mode == null) return '未设置';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text('${widget.client.name} - 课程完整记录'),
        backgroundColor: const Color(0xFF2A2A2A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourseRecords,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
            )
          : _error != null
          ? _buildErrorWidget()
          : _courseRecords.isEmpty
          ? _buildEmptyWidget()
          : _buildRecordsList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCourseRecords,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            '暂无课程记录',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('该客户还没有任何课程记录', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    // 按日期分组记录
    final Map<String, List<course_record.CourseRecord>> groupedRecords = {};
    for (var record in _courseRecords) {
      final dateKey = _formatDate(record.courseDate);
      if (!groupedRecords.containsKey(dateKey)) {
        groupedRecords[dateKey] = [];
      }
      groupedRecords[dateKey]!.add(record);
    }

    // 按日期排序
    final sortedDates = groupedRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        // 统计信息
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '统计信息',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatItem('总课程数', '${_courseRecords.length}'),
                  const SizedBox(width: 20),
                  _buildStatItem('本月课程', _getMonthlyCount().toString()),
                ],
              ),
            ],
          ),
        ),

        // 记录列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final recordsForDate = groupedRecords[date]!;
              return _buildDateGroup(date, recordsForDate);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateGroup(
    String date,
    List<course_record.CourseRecord> records,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期标题
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            date,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 该日期的所有记录
        ...records.map((record) => _buildRecordCard(record)).toList(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(course_record.CourseRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseRecordDetailScreen(record: record),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 日期和时间
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(record.courseDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        record.startTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 训练模式
                if (record.trainingMode != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTrainingModeText(record.trainingMode),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // 动作数量
                Row(
                  children: [
                    const Icon(Icons.list, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${record.actionTrainings.length} 个动作',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 教练记录预览
                if (record.coachRecord?.isNotEmpty == true) ...[
                  Text(
                    '教练记录: ${record.coachRecord!.substring(0, record.coachRecord!.length > 30 ? 30 : record.coachRecord!.length)}${record.coachRecord!.length > 30 ? '...' : ''}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                ],

                // 查看详情提示
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '点击查看详情',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[600],
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getMonthlyCount() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _courseRecords.where((record) {
      return record.courseDate.isAfter(
            startOfMonth.subtract(const Duration(days: 1)),
          ) &&
          record.courseDate.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).length;
  }
}
