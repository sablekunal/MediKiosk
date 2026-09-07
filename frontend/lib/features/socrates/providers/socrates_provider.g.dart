// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socrates_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SocratesController)
final socratesControllerProvider = SocratesControllerProvider._();

final class SocratesControllerProvider
    extends $NotifierProvider<SocratesController, SocratesData> {
  SocratesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socratesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socratesControllerHash();

  @$internal
  @override
  SocratesController create() => SocratesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocratesData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocratesData>(value),
    );
  }
}

String _$socratesControllerHash() =>
    r'269139dc2828da6e479de655a4a2acbb28de55aa';

abstract class _$SocratesController extends $Notifier<SocratesData> {
  SocratesData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SocratesData, SocratesData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SocratesData, SocratesData>,
              SocratesData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
