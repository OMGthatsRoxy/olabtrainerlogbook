import 'package:flutter/material.dart';

class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final String description;
  final String difficulty;
  final String equipment;
  final List<String> muscleGroups;
  final List<String> instructions;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.description,
    required this.difficulty,
    required this.equipment,
    required this.muscleGroups,
    required this.instructions,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      bodyPart: json['bodyPart'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? '初级',
      equipment: json['equipment'] ?? '无器械',
      muscleGroups: List<String>.from(json['muscleGroups'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bodyPart': bodyPart,
      'description': description,
      'difficulty': difficulty,
      'equipment': equipment,
      'muscleGroups': muscleGroups,
      'instructions': instructions,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? bodyPart,
    String? description,
    String? difficulty,
    String? equipment,
    List<String>? muscleGroups,
    List<String>? instructions,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      instructions: instructions ?? this.instructions,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BodyPart {
  final String name;
  final String icon;
  final Color color;

  BodyPart({required this.name, required this.icon, required this.color});
}

// 预定义的身体部位数据
final List<BodyPart> bodyParts = [
  BodyPart(name: '胸部', icon: 'fitness_center', color: Colors.red),
  BodyPart(name: '背部', icon: 'accessibility', color: Colors.blue),
  BodyPart(name: '腿部', icon: 'directions_run', color: Colors.green),
  BodyPart(name: '肩部', icon: 'sports_gymnastics', color: Colors.orange),
  BodyPart(name: '手臂', icon: 'fitness_center', color: Colors.purple),
  BodyPart(name: '核心', icon: 'center_focus_strong', color: Colors.teal),
];

// 课程记录模型
class CourseRecord {
  final String id;
  final String scheduleId;
  final String clientId;
  final String clientName;
  final DateTime courseDate;
  final String startTime;
  final String trainingMode;
  final List<ExerciseSet> exercises;
  final String coachRecord;
  final String studentPerformance;
  final String nextGoal;
  final DateTime createdAt;

  CourseRecord({
    required this.id,
    required this.scheduleId,
    required this.clientId,
    required this.clientName,
    required this.courseDate,
    required this.startTime,
    required this.trainingMode,
    required this.exercises,
    required this.coachRecord,
    required this.studentPerformance,
    required this.nextGoal,
    required this.createdAt,
  });

  factory CourseRecord.fromJson(Map<String, dynamic> json) {
    return CourseRecord(
      id: json['id'],
      scheduleId: json['scheduleId'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      courseDate: DateTime.parse(json['courseDate']),
      startTime: json['startTime'],
      trainingMode: json['trainingMode'],
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseSet.fromJson(e))
          .toList(),
      coachRecord: json['coachRecord'] ?? '',
      studentPerformance: json['studentPerformance'] ?? '',
      nextGoal: json['nextGoal'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'clientId': clientId,
      'clientName': clientName,
      'courseDate': courseDate.toIso8601String(),
      'startTime': startTime,
      'trainingMode': trainingMode,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'coachRecord': coachRecord,
      'studentPerformance': studentPerformance,
      'nextGoal': nextGoal,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// 运动组模型
class ExerciseSet {
  final String id;
  final String exerciseName;
  final String bodyPart;
  final double weight;
  final int sets;
  final int reps;

  ExerciseSet({
    required this.id,
    required this.exerciseName,
    required this.bodyPart,
    required this.weight,
    required this.sets,
    required this.reps,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id'],
      exerciseName: json['exerciseName'],
      bodyPart: json['bodyPart'],
      weight: (json['weight'] ?? 0).toDouble(),
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'bodyPart': bodyPart,
      'weight': weight,
      'sets': sets,
      'reps': reps,
    };
  }
}
