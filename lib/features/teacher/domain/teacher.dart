import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Teacher {
  final String id;
  final String academyId;
  final String name;
  final String subject;
  final String qualification;
  final String phone;
  final double salary;
  final DateTime joiningDate;
  final String gender;

  const Teacher({
    required this.id,
    required this.academyId,
    required this.name,
    required this.subject,
    required this.qualification,
    required this.phone,
    required this.salary,
    required this.joiningDate,
    this.gender = 'Not Specified',
  });

  Teacher copyWith({
    String? name,
    String? subject,
    String? qualification,
    String? phone,
    double? salary,
    String? gender,
  }) {
    return Teacher(
      id: id,
      academyId: academyId,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      qualification: qualification ?? this.qualification,
      phone: phone ?? this.phone,
      salary: salary ?? this.salary,
      joiningDate: joiningDate,
      gender: gender ?? this.gender,
    );
  }

  factory Teacher.fromMap(Map<String, dynamic> data, String id) {
    return Teacher(
      id: id,
      academyId: data['academyId'] ?? '',
      name: data['name'] ?? '',
      subject: data['subject'] ?? '',
      qualification: data['qualification'] ?? '',
      phone: data['phone'] ?? '',
      salary: (data['salary'] as num?)?.toDouble() ?? 0.0,
      joiningDate: (data['joiningDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gender: data['gender'] ?? 'Not Specified',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacherId': id,
      'academyId': academyId,
      'name': name,
      'nameLower': name.toLowerCase(),
      'subject': subject,
      'qualification': qualification,
      'phone': phone,
      'salary': salary,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'gender': gender,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
