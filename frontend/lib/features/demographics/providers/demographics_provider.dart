import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/turn_response.dart';

part 'demographics_provider.freezed.dart';
part 'demographics_provider.g.dart';

// ---------------------------------------------------------------------------
// Patient form state (local only — collected in registration form)
// ---------------------------------------------------------------------------

@freezed
abstract class PatientFormData with _$PatientFormData {
  const factory PatientFormData({
    @Default('') String givenName,
    @Default('') String familyName,
    @Default('') String birthDate,   // YYYY-MM-DD
    @Default('') String gender,      // male | female | other | unknown
    @Default('') String identifier,  // ABHA ID
    @Default('en') String language,
    @Default([]) List<String> scannedDocuments,
    @Default('') String ocrSummary,
  }) = _PatientFormData;
}

@Riverpod(keepAlive: true)
class PatientFormController extends _$PatientFormController {
  @override
  PatientFormData build() => const PatientFormData();

  void updateGivenName(String v) => state = state.copyWith(givenName: v);
  void updateFamilyName(String v) => state = state.copyWith(familyName: v);
  void updateBirthDate(String v) => state = state.copyWith(birthDate: v);
  void updateGender(String v) => state = state.copyWith(gender: v.toLowerCase());
  void updateIdentifier(String v) => state = state.copyWith(identifier: v);
  void addScannedDocument(String ocrText) => state = state.copyWith(
        scannedDocuments: [...state.scannedDocuments, ocrText],
        ocrSummary: state.ocrSummary.isEmpty ? ocrText : '${state.ocrSummary}\n---\n$ocrText',
      );
  void setPatient(PatientFormData p) => state = p;
  void reset() => state = const PatientFormData();
}

// ---------------------------------------------------------------------------
// Session controller — single source of truth for the entire intake flow
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  AsyncValue<TurnResponse?> build() => const AsyncValue.data(null);

  String? get sessionId => state.value?.sessionId;

  void setTurn(TurnResponse turn) {
    state = AsyncValue.data(turn);
  }

  /// Start a new session, pre-filling patient demographics so the backend
  /// immediately skips straight to the chief complaint question.
  Future<void> startSession(PatientFormData patient) async {
    state = const AsyncValue.loading();
    try {
      final dio = DioClient().dio;
      final payload = {
        'patient': {
          if (patient.identifier.isNotEmpty) 'identifier': patient.identifier,
          if (patient.givenName.isNotEmpty) 'given_name': patient.givenName,
          if (patient.familyName.isNotEmpty) 'family_name': patient.familyName,
          if (patient.birthDate.isNotEmpty) 'birth_date': patient.birthDate,
          if (patient.gender.isNotEmpty) 'gender': patient.gender,
          'language': patient.language,
        }
      };
      final response = await dio.post(ApiConstants.sessionStart, data: payload);
      state = AsyncValue.data(TurnResponse.fromJson(response.data as Map<String, dynamic>));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Submit a turn — either a free-text transcript or a pre-selected enum value.
  Future<void> submitTurn({String transcript = '', String? selectedValue}) async {
    final id = sessionId;
    if (id == null) return;
    state = const AsyncValue.loading();
    try {
      final dio = DioClient().dio;
      final response = await dio.post(
        ApiConstants.sessionTurn(id),
        data: {
          'transcript': transcript,
          if (selectedValue != null) 'selected_value': selectedValue,
        },
      );
      state = AsyncValue.data(TurnResponse.fromJson(response.data as Map<String, dynamic>));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reset the entire intake session for the next patient
  void resetSession() {
    state = const AsyncValue.data(null);
  }
}
