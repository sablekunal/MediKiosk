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
        isAutoDispose: false,
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
    r'2a16f467080a0edc996b08641c51621ba8cc1861';

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
        isAutoDispose: false,
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

String _$sessionControllerHash() => r'e3ebba2acc89269b2eca4ec03c6f447896e650c4';

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
