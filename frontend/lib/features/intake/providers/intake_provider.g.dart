// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intake_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IntakeController)
final intakeControllerProvider = IntakeControllerProvider._();

final class IntakeControllerProvider
    extends
        $NotifierProvider<IntakeController, AsyncValue<IntakeTurnResponse?>> {
  IntakeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'intakeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$intakeControllerHash();

  @$internal
  @override
  IntakeController create() => IntakeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<IntakeTurnResponse?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<IntakeTurnResponse?>>(
        value,
      ),
    );
  }
}

String _$intakeControllerHash() => r'701d3d7159f740f394c054802247fc489dd5f981';

abstract class _$IntakeController
    extends $Notifier<AsyncValue<IntakeTurnResponse?>> {
  AsyncValue<IntakeTurnResponse?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<IntakeTurnResponse?>,
              AsyncValue<IntakeTurnResponse?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<IntakeTurnResponse?>,
                AsyncValue<IntakeTurnResponse?>
              >,
              AsyncValue<IntakeTurnResponse?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
