import 'exercise.dart';

enum TrainingMode {
  strength, // 力量训练
  cardio, // 有氧训练
  flexibility, // 柔韧性训练
  functional, // 功能性训练
  hiit, // 高强度间歇训练
  yoga, // 瑜伽
  pilates, // 普拉提
  boxing, // 拳击
  swimming, // 游泳
  other, // 其他
}

class ExerciseSet {
  final int setNumber;
  final double? weight;
  final int? reps;
  final int? duration; // 秒数
  final String? notes;

  ExerciseSet({
    required this.setNumber,
    this.weight,
    this.reps,
    this.duration,
    this.notes,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      setNumber: json['setNumber'],
      weight: json['weight']?.toDouble(),
      reps: json['reps'],
      duration: json['duration'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'duration': duration,
      'notes': notes,
    };
  }
}

class ActionTraining {
  final String id;
  final String category; // 胸、背、肩膀、手臂、臀、腿、全身
  final String? exerciseName;
  final String? exerciseId;
  final List<ExerciseSet> sets;
  final String? notes;

  ActionTraining({
    required this.id,
    required this.category,
    this.exerciseName,
    this.exerciseId,
    required this.sets,
    this.notes,
  });

  factory ActionTraining.fromJson(Map<String, dynamic> json) {
    return ActionTraining(
      id: json['id'],
      category: json['category'],
      exerciseName: json['exerciseName'],
      exerciseId: json['exerciseId'],
      sets: (json['sets'] as List)
          .map((set) => ExerciseSet.fromJson(set))
          .toList(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'exerciseName': exerciseName,
      'exerciseId': exerciseId,
      'sets': sets.map((set) => set.toJson()).toList(),
      'notes': notes,
    };
  }
}

class CourseRecord {
  final String id;
  final String clientId;
  final String clientName;
  final DateTime courseDate;
  final String startTime;
  final TrainingMode? trainingMode;
  final List<ActionTraining> actionTrainings;
  final String? coachRecord;
  final String? studentPerformance;
  final String? nextGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseRecord({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.courseDate,
    required this.startTime,
    this.trainingMode,
    required this.actionTrainings,
    this.coachRecord,
    this.studentPerformance,
    this.nextGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseRecord.fromJson(Map<String, dynamic> json) {
    return CourseRecord(
      id: json['id'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      courseDate: DateTime.parse(json['courseDate']),
      startTime: json['startTime'],
      trainingMode: json['trainingMode'] != null
          ? TrainingMode.values.firstWhere(
              (e) => e.toString() == 'TrainingMode.${json['trainingMode']}',
            )
          : null,
      actionTrainings: (json['actionTrainings'] as List)
          .map((action) => ActionTraining.fromJson(action))
          .toList(),
      coachRecord: json['coachRecord'],
      studentPerformance: json['studentPerformance'],
      nextGoal: json['nextGoal'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'courseDate': courseDate.toIso8601String(),
      'startTime': startTime,
      'trainingMode': trainingMode?.toString().split('.').last,
      'actionTrainings': actionTrainings
          .map((action) => action.toJson())
          .toList(),
      'coachRecord': coachRecord,
      'studentPerformance': studentPerformance,
      'nextGoal': nextGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CourseRecord copyWith({
    String? id,
    String? clientId,
    String? clientName,
    DateTime? courseDate,
    String? startTime,
    TrainingMode? trainingMode,
    List<ActionTraining>? actionTrainings,
    String? coachRecord,
    String? studentPerformance,
    String? nextGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseRecord(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      courseDate: courseDate ?? this.courseDate,
      startTime: startTime ?? this.startTime,
      trainingMode: trainingMode ?? this.trainingMode,
      actionTrainings: actionTrainings ?? this.actionTrainings,
      coachRecord: coachRecord ?? this.coachRecord,
      studentPerformance: studentPerformance ?? this.studentPerformance,
      nextGoal: nextGoal ?? this.nextGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
