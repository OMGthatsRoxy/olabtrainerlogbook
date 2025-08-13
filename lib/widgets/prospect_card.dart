import 'package:flutter/material.dart';
import '../models/prospect.dart';

class ProspectCard extends StatelessWidget {
  final Prospect prospect;
  final VoidCallback onTap;

  const ProspectCard({
    super.key,
    required this.prospect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
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
                  prospect.name.isNotEmpty ? prospect.name[0] : '?',
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
                            prospect.name,
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
                            color: _getStatusColor(prospect.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(prospect.status),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prospect.phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getSourceText(prospect.source),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '联系时间: ${_formatDate(prospect.contactDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ProspectStatus status) {
    switch (status) {
      case ProspectStatus.contacted:
        return Colors.blue;
      case ProspectStatus.interested:
        return Colors.green;
      case ProspectStatus.notInterested:
        return Colors.red;
      case ProspectStatus.converted:
        return Colors.purple;
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

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}
