// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demographics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PatientFormController)
final patientFormControllerProvider = PatientFormControllerProvider._();

final class PatientFormControllerProvider
    extends $NotifierProvider<PatientFormController, PatientFormData> {
  PatientFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'patientFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$patientFormControllerHash();

  @$internal
  @override
  PatientFormController create() => PatientFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PatientFormData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PatientFormData>(value),
    );
  }
}

String _$patientFormControllerHash() =>
    r'874f9dcdece0a9961a084f9ee2b319c41dd01238';

abstract class _$PatientFormController extends $Notifier<PatientFormData> {
  PatientFormData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PatientFormData, PatientFormData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PatientFormData, PatientFormData>,
              PatientFormData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

final class SessionControllerProvider
    extends $NotifierProvider<SessionController, AsyncValue<TurnResponse?>> {
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<TurnResponse?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<TurnResponse?>>(value),
    );
  }
}

String _$sessionControllerHash() => r'56b04e19b8292a854385a9493320734f9ffc250c';

abstract class _$SessionController
    extends $Notifier<AsyncValue<TurnResponse?>> {
  AsyncValue<TurnResponse?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TurnResponse?>, AsyncValue<TurnResponse?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TurnResponse?>, AsyncValue<TurnResponse?>>,
              AsyncValue<TurnResponse?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
