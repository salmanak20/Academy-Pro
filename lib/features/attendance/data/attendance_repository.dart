import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/attendance.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(firestore: FirebaseFirestore.instance);
});

class AttendanceRepository {
  final FirebaseFirestore _firestore;

  AttendanceRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _attendance => _firestore.collection('attendance');

  Stream<List<Attendance>> watchAttendance(String academyId, PersonType type, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _attendance
        .where('academyId', isEqualTo: academyId)
        .where('type', isEqualTo: type.name)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Attendance.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> markAttendance(Attendance attendance) async {
    final date = attendance.date;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    final id = attendance.id.isNotEmpty 
        ? attendance.id 
        : '${attendance.academyId}_${attendance.type.name}_${attendance.personId}_${normalizedDate.year}_${normalizedDate.month}_${normalizedDate.day}';

    final newAttendance = Attendance(
      id: id,
      academyId: attendance.academyId,
      type: attendance.type,
      personId: attendance.personId,
      date: normalizedDate,
      status: attendance.status,
    );

    // Upsert using SetOptions to prevent duplicates
    await _attendance.doc(id).set(newAttendance.toMap(), SetOptions(merge: true));
  }
}
