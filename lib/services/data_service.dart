import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/client.dart';
import '../models/schedule.dart';
import '../models/prospect.dart';
import '../models/user_profile.dart';
import '../models/exercise.dart';
import '../models/package.dart';
import '../models/course_record.dart' as course_record;

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 获取当前用户ID
  String? get currentUserId => _auth.currentUser?.uid;

  // 检查用户是否已登录
  bool get isLoggedIn => _auth.currentUser != null;

  // 获取当前用户邮箱
  String? get currentUserEmail => _auth.currentUser?.email;

  // 客户管理
  Future<List<Client>> getClients() async {
    try {
      if (currentUserId == null) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('clients')
          .orderBy('joinDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Client.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addClient(Client client) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('clients')
          .add(client.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateClient(Client client) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('clients')
          .doc(client.id)
          .update(client.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteClient(String clientId) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('clients')
          .doc(clientId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 课程排程管理
  Future<List<Schedule>> getSchedules() async {
    try {
      if (currentUserId == null) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('schedules')
          .orderBy('date') // 只按日期排序，避免复合索引错误
          .get();

      final schedules = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Schedule.fromJson({...data, 'id': doc.id});
      }).toList();

      // 在内存中按日期和时间排序
      schedules.sort((a, b) {
        final dateComparison = a.date.compareTo(b.date);
        if (dateComparison != 0) return dateComparison;
        return a.startTime.compareTo(b.startTime);
      });

      return schedules;
    } catch (e) {
      return [];
    }
  }

  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    try {
      if (currentUserId == null) return [];

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('schedules')
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .orderBy('startTime')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Schedule.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Schedule>> getSchedulesForDate(DateTime date) async {
    try {
      if (currentUserId == null) return [];

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('schedules')
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get(); // 移除orderBy，避免复合索引错误

      final schedules = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Schedule.fromJson({...data, 'id': doc.id});
      }).toList();

      // 在内存中按开始时间排序
      schedules.sort((a, b) => a.startTime.compareTo(b.startTime));

      return schedules;
    } catch (e) {
      return [];
    }
  }

  Future<bool> addSchedule(Schedule schedule) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('schedules')
          .add(schedule.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSchedule(Schedule schedule) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('schedules')
          .doc(schedule.id)
          .update(schedule.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('schedules')
          .doc(scheduleId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 潜在客户管理
  Future<List<Prospect>> getProspects() async {
    try {
      if (currentUserId == null) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('prospects')
          .orderBy('contactDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Prospect.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addProspect(Prospect prospect) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('prospects')
          .add(prospect.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProspect(Prospect prospect) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('prospects')
          .doc(prospect.id)
          .update(prospect.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProspect(String prospectId) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('prospects')
          .doc(prospectId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 实时数据监听
  Stream<List<Client>> streamClients() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('clients')
        .orderBy('joinDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Client.fromJson({...data, 'id': doc.id});
          }).toList();
        });
  }

  Stream<List<Schedule>> streamSchedules() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('schedules')
        .orderBy('date') // 只按日期排序，避免复合索引错误
        .snapshots()
        .map((snapshot) {
          final schedules = snapshot.docs.map((doc) {
            final data = doc.data();
            return Schedule.fromJson({...data, 'id': doc.id});
          }).toList();

          // 在内存中按日期和时间排序
          schedules.sort((a, b) {
            final dateComparison = a.date.compareTo(b.date);
            if (dateComparison != 0) return dateComparison;
            return a.startTime.compareTo(b.startTime);
          });

          return schedules;
        });
  }

  Stream<List<Prospect>> streamProspects() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('prospects')
        .orderBy('contactDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Prospect.fromJson({...data, 'id': doc.id});
          }).toList();
        });
  }

  // 用户资料管理
  Future<UserProfile?> getUserProfile() async {
    try {
      if (currentUserId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('profile')
          .doc('personal')
          .get();

      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('profile')
          .doc('personal')
          .set(profile.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<UserProfile?> streamUserProfile() {
    if (currentUserId == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('profile')
        .doc('personal')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return UserProfile.fromJson(doc.data()!);
          }
          return null;
        });
  }

  // 动作库管理
  Future<List<Exercise>> getExercises({String? bodyPart}) async {
    try {
      if (currentUserId == null) return [];

      Query query = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('exercises');

      if (bodyPart != null) {
        query = query.where('bodyPart', isEqualTo: bodyPart);
      }

      // 移除orderBy，避免索引问题
      final QuerySnapshot snapshot = await query.get();

      final exercises = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Exercise.fromJson({...data, 'id': doc.id});
      }).toList();

      // 在内存中排序
      exercises.sort((a, b) => a.name.compareTo(b.name));

      return exercises;
    } catch (e) {
      return [];
    }
  }

  Future<bool> addExercise(Exercise exercise) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('exercises')
          .add(exercise.toJson());

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateExercise(Exercise exercise) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('exercises')
          .doc(exercise.id)
          .update(exercise.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteExercise(String exerciseId) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('exercises')
          .doc(exerciseId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Exercise>> getAllExercises() async {
    try {
      if (currentUserId == null) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('exercises')
          .get();

      final exercises = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Exercise.fromJson({...data, 'id': doc.id});
      }).toList();

      // 在内存中排序
      exercises.sort((a, b) => a.name.compareTo(b.name));

      return exercises;
    } catch (e) {
      return [];
    }
  }

  Stream<List<Exercise>> streamExercises({String? bodyPart}) {
    if (currentUserId == null) return Stream.value([]);

    Query query = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('exercises');

    if (bodyPart != null) {
      query = query.where('bodyPart', isEqualTo: bodyPart);
    }

    return query.snapshots().map((snapshot) {
      final exercises = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Exercise.fromJson({...data, 'id': doc.id});
      }).toList();

      // 调试信息
      return exercises; // 移除排序，在内存中处理
    });
  }

  // 删除用户所有数据
  Future<bool> deleteUserData() async {
    try {
      if (currentUserId == null) return false;

      // 删除用户的所有子集合
      final collections = [
        'clients',
        'schedules',
        'prospects',
        'profile',
        'exercises',
        'packages',
      ];

      for (final collectionName in collections) {
        final collectionRef = _firestore
            .collection('users')
            .doc(currentUserId)
            .collection(collectionName);

        final snapshot = await collectionRef.get();

        // 批量删除集合中的所有文档
        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // 删除用户主文档
      await _firestore.collection('users').doc(currentUserId).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  // 配套管理
  Future<List<Package>> getPackages({String? clientId}) async {
    try {
      if (currentUserId == null) return [];

      Query query = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('packages');

      if (clientId != null) {
        query = query.where('clientId', isEqualTo: clientId);
      }

      // 临时移除orderBy，避免索引错误
      final QuerySnapshot snapshot = await query.get();

      final packages = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Package.fromJson({...data, 'id': doc.id});
      }).toList();

      // 在内存中按创建时间倒序排列
      packages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return packages;
    } catch (e) {
      return [];
    }
  }

  Future<bool> addPackage(Package package) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('packages')
          .add(package.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePackage(Package package) async {
    try {
      if (currentUserId == null) return false;

      // 检查是否需要自动更新状态
      Package updatedPackage = package;
      if (package.remainingSessions <= 0 &&
          package.status == PackageStatus.active) {
        // 剩余课程为0时，自动将状态改为已完成
        updatedPackage = package.copyWith(status: PackageStatus.completed);
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('packages')
          .doc(updatedPackage.id)
          .update(updatedPackage.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePackage(String packageId) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('packages')
          .doc(packageId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Package>> streamPackages({String? clientId}) {
    if (currentUserId == null) return Stream.value([]);

    Query query = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('packages');

    if (clientId != null) {
      query = query.where('clientId', isEqualTo: clientId);
    }

    // 临时移除orderBy，避免索引错误
    // 在内存中排序
    return query.snapshots().map((snapshot) {
      final packages = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Package.fromJson({...data, 'id': doc.id});
      }).toList();

      // 在内存中按创建时间倒序排列
      packages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return packages;
    });
  }

  // 课程记录管理
  Future<List<course_record.CourseRecord>> getCourseRecords() async {
    try {
      if (currentUserId == null) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('courseRecords')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return course_record.CourseRecord.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> addCourseRecord(course_record.CourseRecord record) async {
    try {
      if (currentUserId == null) return null;

      final docRef = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('courseRecords')
          .add(record.toJson());

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateCourseRecord(course_record.CourseRecord record) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('courseRecords')
          .doc(record.id)
          .update(record.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCourseRecord(String recordId) async {
    try {
      if (currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('courseRecords')
          .doc(recordId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<course_record.CourseRecord>> streamCourseRecords() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('courseRecords')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return course_record.CourseRecord.fromJson({...data, 'id': doc.id});
          }).toList();
        });
  }

  // 更新课程状态为已完成
  Future<bool> updateScheduleStatus(
    String scheduleId,
    ScheduleStatus status, {
    String? courseRecordId,
  }) async {
    try {
      if (currentUserId == null) return false;

      final updateData = <String, dynamic>{
        'status': status.toString().split('.').last,
      };

      if (courseRecordId != null) {
        updateData['courseRecordId'] = courseRecordId;
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('schedules')
          .doc(scheduleId)
          .update(updateData);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 根据客户ID获取课程记录
  Future<List<course_record.CourseRecord>> getCourseRecordsByClient(
    String clientId,
  ) async {
    try {
      if (currentUserId == null) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('courseRecords')
          .where('clientId', isEqualTo: clientId)
          .get(); // 移除orderBy，避免复合索引问题

      final records = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return course_record.CourseRecord.fromJson({...data, 'id': doc.id});
      }).toList();

      // 在内存中按创建时间排序
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return records;
    } catch (e) {
      return [];
    }
  }
}
