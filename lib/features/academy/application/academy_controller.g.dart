// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academy_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(academiesStream)
final academiesStreamProvider = AcademiesStreamProvider._();

final class AcademiesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Academy>>,
          List<Academy>,
          Stream<List<Academy>>
        >
    with $FutureModifier<List<Academy>>, $StreamProvider<List<Academy>> {
  AcademiesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'academiesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$academiesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Academy>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Academy>> create(Ref ref) {
    return academiesStream(ref);
  }
}

String _$academiesStreamHash() => r'017657f6c46cb42d0989689d280262d3208f3c7a';

@ProviderFor(AcademyController)
final academyControllerProvider = AcademyControllerProvider._();

final class AcademyControllerProvider
    extends $AsyncNotifierProvider<AcademyController, void> {
  AcademyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'academyControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$academyControllerHash();

  @$internal
  @override
  AcademyController create() => AcademyController();
}

String _$academyControllerHash() => r'd0512852bed7cd79caa6711ccc014dce1bbdbdbb';

abstract class _$AcademyController extends $AsyncNotifier<void> {
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
