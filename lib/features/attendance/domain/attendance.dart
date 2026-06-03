import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { present, absent, leave }

enum PersonType { student, teacher }

class Attendance {
  final String id;
  final String academyId;
  final PersonType type;
  final String personId;
  final DateTime date;
  final AttendanceStatus status;

  const Attendance({
    required this.id,
    required this.academyId,
    required this.type,
    required this.personId,
    required this.date,
    required this.status,
  });

  Attendance copyWith({
    AttendanceStatus? status,
  }) {
    return Attendance(
      id: id,
      academyId: academyId,
      type: type,
      personId: personId,
      date: date,
      status: status ?? this.status,
    );
  }

  factory Attendance.fromMap(Map<String, dynamic> data, String id) {
    return Attendance(
      id: id,
      academyId: data['academyId'] ?? '',
      type: data['type'] == 'teacher' ? PersonType.teacher : PersonType.student,
      personId: data['personId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'absent'),
        orElse: () => AttendanceStatus.absent,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'academyId': academyId,
      'type': type.name,
      'personId': personId,
      'date': Timestamp.fromDate(date),
      'status': status.name,
    };
  }
}