import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/teacher_repository.dart';
import '../domain/teacher.dart';
import '../../auth/presentation/providers/auth_provider.dart';

part 'teacher_controller.g.dart';

@riverpod
Stream<List<Teacher>> teachersStream(Ref ref) {
  final user = ref.watch(authControllerProvider).value;
  if (user == null || user.academyId == null) {
    return Stream.value([]);
  }
  return ref.watch(teacherRepositoryProvider).watchTeachers(user.academyId!);
}

@riverpod
class TeacherController extends _$TeacherController {
  @override
  FutureOr<void> build() {}

  Future<void> createTeacher({
    required String name,
    required String subject,
    required String qualification,
    required String phone,
    required double salary,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authControllerProvider).value;
      if (user == null || user.academyId == null) {
        throw Exception('User is not assigned to an academy.');
      }

      final teacher = Teacher(
        id: '', // Will be generated
        academyId: user.academyId!,
        name: name,
        subject: subject,
        qualification: qualification,
        phone: phone,
        salary: salary,
        joiningDate: DateTime.now(),
      );
      
      await ref.read(teacherRepositoryProvider).createTeacher(teacher);
    });
  }

  Future<void> updateTeacher(Teacher teacher) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(teacherRepositoryProvider).updateTeacher(teacher);
    });
  }

  Future<void> deleteTeacher(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(teacherRepositoryProvider).deleteTeacher(id);
    });
  }
}