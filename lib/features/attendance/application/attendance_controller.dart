import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance.dart';
import '../../auth/presentation/providers/auth_provider.dart';

part 'attendance_controller.g.dart';

class AttendanceStateData {
  final DateTime selectedDate;
  final PersonType selectedType;

  AttendanceStateData({
    required this.selectedDate,
    required this.selectedType,
  });

  AttendanceStateData copyWith({
    DateTime? selectedDate,
    PersonType? selectedType,
  }) {
    return AttendanceStateData(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

@riverpod
class AttendanceState extends _$AttendanceState {
  @override
  AttendanceStateData build() {
    return AttendanceStateData(
      selectedDate: DateTime.now(),
      selectedType: PersonType.student,
    );
  }

  void updateDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void updateType(PersonType type) {
    state = state.copyWith(selectedType: type);
  }
}

@riverpod
Stream<List<Attendance>> attendanceStream(Ref ref) {
  final user = ref.watch(authControllerProvider).value;
  final state = ref.watch(attendanceStateProvider);
  
  if (user == null || user.academyId == null) {
    return Stream.value([]);
  }
  
  return ref.watch(attendanceRepositoryProvider).watchAttendance(
        user.academyId!,
        state.selectedType,
        state.selectedDate,
      );
}

@riverpod
class AttendanceController extends _$AttendanceController {
  @override
  FutureOr<void> build() {}

  Future<void> markAttendance({
    required String personId,
    required AttendanceStatus status,
    String? existingId, // null if not marked yet
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authControllerProvider).value;
      final uiState = ref.read(attendanceStateProvider);

      if (user == null || user.academyId == null) {
        throw Exception('User is not assigned to an academy.');
      }

      final attendance = Attendance(
        id: existingId ?? '',
        academyId: user.academyId!,
        type: uiState.selectedType,
        personId: personId,
        date: uiState.selectedDate,
        status: status,
      );
      
      await ref.read(attendanceRepositoryProvider).markAttendance(attendance);
    });
  }
}