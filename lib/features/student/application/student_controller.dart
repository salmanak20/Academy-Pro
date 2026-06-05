import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/student_repository.dart';
import '../domain/student.dart';
import '../../auth/presentation/providers/auth_provider.dart';

part 'student_controller.g.dart';

@riverpod
Stream<List<Student>> studentsStream(Ref ref) {
  final user = ref.watch(authControllerProvider).value;
  if (user == null || user.academyId == null) {
    return Stream.value([]);
  }
  return ref.watch(studentRepositoryProvider).watchStudents(user.academyId!);
}

@Riverpod(keepAlive: true)
class StudentController extends _$StudentController {
  @override
  FutureOr<void> build() {}

  Future<void> createStudent({
    required String name,
    required String fatherName,
    required String studentClass,
    required String rollNumber,
    required String phone,
    required String address,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authControllerProvider).value;
      if (user == null || user.academyId == null) {
        throw Exception('User is not assigned to an academy.');
      }

      final student = Student(
        id: '', // Will be generated
        academyId: user.academyId!,
        name: name,
        fatherName: fatherName,
        studentClass: studentClass,
        rollNumber: rollNumber,
        phone: phone,
        address: address,
        admissionDate: DateTime.now(),
      );
      
      await ref.read(studentRepositoryProvider).createStudent(student);
    });
  }

  Future<void> updateStudent(Student student) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(studentRepositoryProvider).updateStudent(student);
    });
  }

  Future<void> deleteStudent(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(studentRepositoryProvider).deleteStudent(id);
    });
  }
}