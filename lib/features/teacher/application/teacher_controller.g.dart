// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(teachersStream)
final teachersStreamProvider = TeachersStreamProvider._();

final class TeachersStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Teacher>>,
          List<Teacher>,
          Stream<List<Teacher>>
        >
    with $FutureModifier<List<Teacher>>, $StreamProvider<List<Teacher>> {
  TeachersStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teachersStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teachersStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Teacher>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Teacher>> create(Ref ref) {
    return teachersStream(ref);
  }
}

String _$teachersStreamHash() => r'4d743c9e112833d9c3e3966724522d3db13b8ee2';

@ProviderFor(TeacherController)
final teacherControllerProvider = TeacherControllerProvider._();

final class TeacherControllerProvider
    extends $AsyncNotifierProvider<TeacherController, void> {
  TeacherControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teacherControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teacherControllerHash();

  @$internal
  @override
  TeacherController create() => TeacherController();
}

String _$teacherControllerHash() => r'4f305c64cd383e960da4d284ad2d2a4f35d1f7db';

abstract class _$TeacherController extends $AsyncNotifier<void> {
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
