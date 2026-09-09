// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HealthController)
final healthControllerProvider = HealthControllerProvider._();

final class HealthControllerProvider
    extends $NotifierProvider<HealthController, BackendStatus> {
  HealthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthControllerHash();

  @$internal
  @override
  HealthController create() => HealthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackendStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackendStatus>(value),
    );
  }
}

String _$healthControllerHash() => r'2c2e72465766b52aa22c31275bd20f08d59506fd';

abstract class _$HealthController extends $Notifier<BackendStatus> {
  BackendStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BackendStatus, BackendStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BackendStatus, BackendStatus>,
              BackendStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
