// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayurveda_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AyurvedaController)
final ayurvedaControllerProvider = AyurvedaControllerProvider._();

final class AyurvedaControllerProvider
    extends $NotifierProvider<AyurvedaController, AyurvedaData> {
  AyurvedaControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ayurvedaControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ayurvedaControllerHash();

  @$internal
  @override
  AyurvedaController create() => AyurvedaController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AyurvedaData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AyurvedaData>(value),
    );
  }
}

String _$ayurvedaControllerHash() =>
    r'cc66d197ef7177e86363d6c4458fd07dd4a95787';

abstract class _$AyurvedaController extends $Notifier<AyurvedaData> {
  AyurvedaData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AyurvedaData, AyurvedaData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AyurvedaData, AyurvedaData>,
              AyurvedaData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
