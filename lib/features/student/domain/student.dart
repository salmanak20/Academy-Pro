import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String academyId;
  final String name;
  final String fatherName;
  final String studentClass;
  final String rollNumber;
  final String phone;
  final String address;
  final DateTime admissionDate;

  const Student({
    required this.id,
    required this.academyId,
    required this.name,
    required this.fatherName,
    required this.studentClass,
    required this.rollNumber,
    required this.phone,
    required this.address,
    required this.admissionDate,
  });

  Student copyWith({
    String? name,
    String? fatherName,
    String? studentClass,
    String? rollNumber,
    String? phone,
    String? address,
  }) {
    return Student(
      id: id,
      academyId: academyId,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      studentClass: studentClass ?? this.studentClass,
      rollNumber: rollNumber ?? this.rollNumber,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      admissionDate: admissionDate,
    );
  }

  factory Student.fromMap(Map<String, dynamic> data, String id) {
    return Student(
      id: id,
      academyId: data['academyId'] ?? '',
      name: data['name'] ?? '',
      fatherName: data['fatherName'] ?? '',
      studentClass: data['class'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      admissionDate: (data['admissionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': id,
      'academyId': academyId,
      'name': name,
      'nameLower': name.toLowerCase(),
      'fatherName': fatherName,
      'class': studentClass,
      'rollNumber': rollNumber,
      'phone': phone,
      'address': address,
      'admissionDate': Timestamp.fromDate(admissionDate),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
