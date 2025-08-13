import 'package:flutter/material.dart';
import '../models/course_record.dart' as course_record;

class CourseRecordDetailScreen extends StatelessWidget {
  final course_record.CourseRecord record;

  const CourseRecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text('课程记录详情 - ${record.clientName}'),
        backgroundColor: const Color(0xFF2A2A2A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息卡片
            _buildBasicInfoCard(),
            const SizedBox(height: 20),

            // 训练模式卡片
            if (record.trainingMode != null) ...[
              _buildTrainingModeCard(),
              const SizedBox(height: 20),
            ],

            // 动作训练卡片
            _buildActionTrainingCard(),
            const SizedBox(height: 20),

            // 教练记录卡片
            if (record.coachRecord?.isNotEmpty == true) ...[
              _buildCoachRecordCard(),
              const SizedBox(height: 20),
            ],

            // 学员表现卡片
            if (record.studentPerformance?.isNotEmpty == true) ...[
              _buildStudentPerformanceCard(),
              const SizedBox(height: 20),
            ],

            // 下次目标卡片
            if (record.nextGoal?.isNotEmpty == true) ...[
              _buildNextGoalCard(),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
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
            '基本信息',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('学员姓名', record.clientName),
          _buildInfoRow('课程日期', _formatDate(record.courseDate)),
          _buildInfoRow('开始时间', record.startTime),
          _buildInfoRow('创建时间', _formatDateTime(record.createdAt)),
          _buildInfoRow('更新时间', _formatDateTime(record.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildTrainingModeCard() {
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
            '训练模式',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getTrainingModeText(record.trainingMode!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTrainingCard() {
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
            '动作训练',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...record.actionTrainings.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return _buildActionTrainingItem(action, index + 1);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionTrainingItem(
    course_record.ActionTraining action,
    int actionNumber,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '动作$actionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  action.category,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (action.exerciseName != null) ...[
            const SizedBox(height: 12),
            Text(
              '动作名称: ${action.exerciseName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            '训练组数:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...action.sets.map((set) => _buildSetItem(set)).toList(),
          if (action.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              '备注: ${action.notes}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSetItem(course_record.ExerciseSet set) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '第${set.setNumber}组',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          if (set.weight != null) ...[
            Text(
              '重量: ${set.weight}kg',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(width: 16),
          ],
          if (set.reps != null) ...[
            Text(
              '次数: ${set.reps}次',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(width: 16),
          ],
          if (set.duration != null) ...[
            Text(
              '时长: ${set.duration}秒',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoachRecordCard() {
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
            '教练记录',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            record.coachRecord!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentPerformanceCard() {
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
            '学员表现',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            record.studentPerformance!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextGoalCard() {
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
            '下次目标',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            record.nextGoal!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getTrainingModeText(course_record.TrainingMode mode) {
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

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
