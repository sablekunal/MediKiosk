import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/patient.dart';
import '../../../core/network/dio_client.dart';
import '../data/models/session.dart';
import '../../../core/constants/api_constants.dart';

part 'demographics_provider.g.dart';

@riverpod
class PatientRegistration extends _$PatientRegistration {
  @override
  Patient build() => const Patient();

  void updateName(String name) => state = state.copyWith(name: name);
  void updateAge(int age) => state = state.copyWith(age: age);
  void updateGender(String gender) => state = state.copyWith(gender: gender);
  void updateMobile(String mobile) => state = state.copyWith(mobileNumber: mobile);
  void updateAbha(String abha) => state = state.copyWith(abhaId: abha);
}

@riverpod
class SessionController extends _$SessionController {
  @override
  AsyncValue<SessionResponse?> build() => const AsyncValue.data(null);

  Future<void> startSession(Patient patient) async {
    state = const AsyncValue.loading();
    try {
      final dio = DioClient().dio;
      final payload = {
        'patient': {
          'identifier': patient.abhaId,
          'given_name': patient.name,
          'gender': patient.gender?.toLowerCase(),
          'language': 'en',
        }
      };
      
      final response = await dio.post(
        ApiConstants.sessionStart,
        data: payload,
      );
      state = AsyncValue.data(SessionResponse.fromJson(response.data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
