// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AttendanceState)
final attendanceStateProvider = AttendanceStateProvider._();

final class AttendanceStateProvider
    extends $NotifierProvider<AttendanceState, AttendanceStateData> {
  AttendanceStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceStateHash();

  @$internal
  @override
  AttendanceState create() => AttendanceState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceStateData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceStateData>(value),
    );
  }
}

String _$attendanceStateHash() => r'8cca8a9273725c7c3cc9367ea246125f55f0ff27';

abstract class _$AttendanceState extends $Notifier<AttendanceStateData> {
  AttendanceStateData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AttendanceStateData, AttendanceStateData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AttendanceStateData, AttendanceStateData>,
              AttendanceStateData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(attendanceStream)
final attendanceStreamProvider = AttendanceStreamProvider._();

final class AttendanceStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Attendance>>,
          List<Attendance>,
          Stream<List<Attendance>>
        >
    with $FutureModifier<List<Attendance>>, $StreamProvider<List<Attendance>> {
  AttendanceStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Attendance>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Attendance>> create(Ref ref) {
    return attendanceStream(ref);
  }
}

String _$attendanceStreamHash() => r'ba506d71400949e8d733006c8bd2c16d53f33d98';

@ProviderFor(AttendanceController)
final attendanceControllerProvider = AttendanceControllerProvider._();

final class AttendanceControllerProvider
    extends $AsyncNotifierProvider<AttendanceController, void> {
  AttendanceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceControllerHash();

  @$internal
  @override
  AttendanceController create() => AttendanceController();
}

String _$attendanceControllerHash() =>
    r'2070bb8bcae14877f134f01390fa3f04ebfc819b';

abstract class _$AttendanceController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
