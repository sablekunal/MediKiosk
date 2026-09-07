// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demographics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PatientRegistration)
final patientRegistrationProvider = PatientRegistrationProvider._();

final class PatientRegistrationProvider
    extends $NotifierProvider<PatientRegistration, Patient> {
  PatientRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'patientRegistrationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$patientRegistrationHash();

  @$internal
  @override
  PatientRegistration create() => PatientRegistration();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Patient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Patient>(value),
    );
  }
}

String _$patientRegistrationHash() =>
    r'83970c52f0e964408bdbefc757310c04fa8c898f';

abstract class _$PatientRegistration extends $Notifier<Patient> {
  Patient build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Patient, Patient>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Patient, Patient>,
              Patient,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

final class SessionControllerProvider
    extends $NotifierProvider<SessionController, AsyncValue<SessionResponse?>> {
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
  Override overrideWithValue(AsyncValue<SessionResponse?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SessionResponse?>>(value),
    );
  }
}

String _$sessionControllerHash() => r'dbdebb6687d56ba8fc9e14cdf370292f042020a6';

abstract class _$SessionController
    extends $Notifier<AsyncValue<SessionResponse?>> {
  AsyncValue<SessionResponse?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<SessionResponse?>, AsyncValue<SessionResponse?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SessionResponse?>,
                AsyncValue<SessionResponse?>
              >,
              AsyncValue<SessionResponse?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
