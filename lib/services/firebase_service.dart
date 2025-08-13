import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';
import '../models/schedule.dart';
import '../models/prospect.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 客户管理
  Future<List<Client>> getClients() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('clients')
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
      await _firestore.collection('clients').add(client.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateClient(Client client) async {
    try {
      await _firestore
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
      await _firestore.collection('clients').doc(clientId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 课程排程管理
  Future<List<Schedule>> getSchedules() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('schedules')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Schedule.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final QuerySnapshot snapshot = await _firestore
          .collection('schedules')
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Schedule.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addSchedule(Schedule schedule) async {
    try {
      await _firestore.collection('schedules').add(schedule.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSchedule(Schedule schedule) async {
    try {
      await _firestore
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
      await _firestore.collection('schedules').doc(scheduleId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 潜在客户管理
  Future<List<Prospect>> getProspects() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('prospects')
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
      await _firestore.collection('prospects').add(prospect.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProspect(Prospect prospect) async {
    try {
      await _firestore
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
      await _firestore.collection('prospects').doc(prospectId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 实时数据监听
  Stream<List<Client>> streamClients() {
    return _firestore.collection('clients').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Client.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  Stream<List<Schedule>> streamSchedules() {
    return _firestore.collection('schedules').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Schedule.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  Stream<List<Prospect>> streamProspects() {
    return _firestore.collection('prospects').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Prospect.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }
}
