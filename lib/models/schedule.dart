enum ScheduleType { personal, group, consultation }

enum ScheduleStatus { confirmed, pending, cancelled, completed }

class Schedule {
  final String id;
  final String clientId;
  final String clientName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final ScheduleType type;
  final ScheduleStatus status;
  final String notes;
  final String? courseRecordId; // 添加课程记录ID字段

  Schedule({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.status,
    required this.notes,
    this.courseRecordId, // 添加课程记录ID参数
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      type: ScheduleType.values.firstWhere(
        (e) => e.toString() == 'ScheduleType.${json['type']}',
      ),
      status: ScheduleStatus.values.firstWhere(
        (e) => e.toString() == 'ScheduleStatus.${json['status']}',
      ),
      notes: json['notes'],
      courseRecordId: json['courseRecordId'], // 解析课程记录ID
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'notes': notes,
      'courseRecordId': courseRecordId, // 序列化课程记录ID
    };
  }

  Schedule copyWith({
    String? id,
    String? clientId,
    String? clientName,
    DateTime? date,
    String? startTime,
    String? endTime,
    ScheduleType? type,
    ScheduleStatus? status,
    String? notes,
    String? courseRecordId, // 添加课程记录ID参数
  }) {
    return Schedule(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      courseRecordId: courseRecordId ?? this.courseRecordId, // 复制课程记录ID
    );
  }
}
