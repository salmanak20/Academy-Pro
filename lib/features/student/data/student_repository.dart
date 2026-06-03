import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/student.dart';
import '../../../core/utils/id_generator.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(firestore: FirebaseFirestore.instance);
});

class StudentRepository {
  final FirebaseFirestore _firestore;

  StudentRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _students => _firestore.collection('students');

  Stream<List<Student>> watchStudents(String academyId) {
    return _students
        .where('academyId', isEqualTo: academyId)
        .snapshots()
        .map((snapshot) {
      final students = snapshot.docs
          .map((doc) => Student.fromMap(doc.data(), doc.id))
          .toList();
      students.sort((a, b) => a.name.compareTo(b.name));
      return students;
    });
  }

  Future<Student> createStudent(Student student) async {
    final id = await IdGenerator.generateStudentId();
    final newStudent = Student(
      id: id,
      academyId: student.academyId,
      name: student.name,
      fatherName: student.fatherName,
      studentClass: student.studentClass,
      rollNumber: student.rollNumber,
      phone: student.phone,
      address: student.address,
      admissionDate: student.admissionDate,
    );
    await _students.doc(id).set(newStudent.toMap());

    // Update academy stats
    await _firestore.collection('academies').doc(student.academyId).update({
      'stats.students': FieldValue.increment(1),
    });

    return newStudent;
  }

  Future<void> updateStudent(Student student) async {
    await _students.doc(student.id).update(student.toMap());
  }

  Future<void> deleteStudent(String id) async {
    final doc = await _students.doc(id).get();
    if (doc.exists) {
      final academyId = doc.data()?['academyId'];
      await _students.doc(id).delete();
      if (academyId != null) {
        await _firestore.collection('academies').doc(academyId).update({
          'stats.students': FieldValue.increment(-1),
        });
      }
    }
  }
}
