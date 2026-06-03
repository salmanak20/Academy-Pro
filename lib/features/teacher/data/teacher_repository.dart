import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/teacher.dart';
import '../../../core/utils/id_generator.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepository(firestore: FirebaseFirestore.instance);
});

class TeacherRepository {
  final FirebaseFirestore _firestore;

  TeacherRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _teachers => _firestore.collection('teachers');

  Stream<List<Teacher>> watchTeachers(String academyId) {
    return _teachers
        .where('academyId', isEqualTo: academyId)
        .snapshots()
        .map((snapshot) {
      final teachers = snapshot.docs
          .map((doc) => Teacher.fromMap(doc.data(), doc.id))
          .toList();
      teachers.sort((a, b) => a.name.compareTo(b.name));
      return teachers;
    });
  }

  Future<Teacher> createTeacher(Teacher teacher) async {
    final id = await IdGenerator.generateTeacherId();
    final newTeacher = Teacher(
      id: id,
      academyId: teacher.academyId,
      name: teacher.name,
      subject: teacher.subject,
      qualification: teacher.qualification,
      phone: teacher.phone,
      salary: teacher.salary,
      joiningDate: teacher.joiningDate,
    );
    await _teachers.doc(id).set(newTeacher.toMap());

    // Update academy stats
    await _firestore.collection('academies').doc(teacher.academyId).update({
      'stats.teachers': FieldValue.increment(1),
    });

    return newTeacher;
  }

  Future<void> updateTeacher(Teacher teacher) async {
    await _teachers.doc(teacher.id).update(teacher.toMap());
  }

  Future<void> deleteTeacher(String id) async {
    final doc = await _teachers.doc(id).get();
    if (doc.exists) {
      final academyId = doc.data()?['academyId'];
      await _teachers.doc(id).delete();
      if (academyId != null) {
        await _firestore.collection('academies').doc(academyId).update({
          'stats.teachers': FieldValue.increment(-1),
        });
      }
    }
  }
}
