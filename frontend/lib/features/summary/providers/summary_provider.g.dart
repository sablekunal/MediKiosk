// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SummaryController)
final summaryControllerProvider = SummaryControllerProvider._();

final class SummaryControllerProvider
    extends
        $NotifierProvider<SummaryController, AsyncValue<CanonicalEncounter?>> {
  SummaryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'summaryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$summaryControllerHash();

  @$internal
  @override
  SummaryController create() => SummaryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CanonicalEncounter?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CanonicalEncounter?>>(
        value,
      ),
    );
  }
}

String _$summaryControllerHash() => r'd4201f1bd301aad65b7ba2ceaf37f9a6acd3d3fb';

abstract class _$SummaryController
    extends $Notifier<AsyncValue<CanonicalEncounter?>> {
  AsyncValue<CanonicalEncounter?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CanonicalEncounter?>,
              AsyncValue<CanonicalEncounter?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CanonicalEncounter?>,
                AsyncValue<CanonicalEncounter?>
              >,
              AsyncValue<CanonicalEncounter?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
