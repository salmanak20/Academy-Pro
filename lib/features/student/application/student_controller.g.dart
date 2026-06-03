// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studentsStream)
final studentsStreamProvider = StudentsStreamProvider._();

final class StudentsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Student>>,
          List<Student>,
          Stream<List<Student>>
        >
    with $FutureModifier<List<Student>>, $StreamProvider<List<Student>> {
  StudentsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Student>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Student>> create(Ref ref) {
    return studentsStream(ref);
  }
}

String _$studentsStreamHash() => r'b39c7e398adecffdb4637d16f8b9d17885c155c8';

@ProviderFor(StudentController)
final studentControllerProvider = StudentControllerProvider._();

final class StudentControllerProvider
    extends $AsyncNotifierProvider<StudentController, void> {
  StudentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentControllerHash();

  @$internal
  @override
  StudentController create() => StudentController();
}

String _$studentControllerHash() => r'68c2b691c7d61842635ddfba3d5ebf27621b4ad2';

abstract class _$StudentController extends $AsyncNotifier<void> {
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
