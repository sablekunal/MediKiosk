import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/encounter.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../demographics/providers/demographics_provider.dart';
import '../../socrates/providers/socrates_provider.dart';
import '../../ayurveda/providers/ayurveda_provider.dart';

part 'summary_provider.g.dart';

@riverpod
class SummaryController extends _$SummaryController {
  @override
  AsyncValue<CanonicalEncounter?> build() {
    final sessionId = ref.watch(sessionControllerProvider).value?.sessionId;
    if (sessionId == null) return const AsyncValue.data(null);
    
    // We can compute the local state first
    final patient = ref.watch(patientRegistrationProvider);
    final western = ref.watch(socratesControllerProvider);
    final ayurveda = ref.watch(ayurvedaControllerProvider);

    return AsyncValue.data(CanonicalEncounter(
      sessionId: sessionId,
      patient: patient,
      westernTriage: western,
      ayurvedicTriage: ayurveda,
    ));
  }

  Future<void> fetchCanonical() async {
    final sessionId = ref.read(sessionControllerProvider).value?.sessionId;
    if (sessionId == null) return;

    state = const AsyncValue.loading();
    try {
      final dio = DioClient().dio;
      final response = await dio.get(ApiConstants.encounterCanonical(sessionId));
      state = AsyncValue.data(CanonicalEncounter.fromJson(response.data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> finalizeEncounter() async {
    final sessionId = ref.read(sessionControllerProvider).value?.sessionId;
    if (sessionId == null) return null;

    try {
      // The new backend doesn't have a specific finalize endpoint, so we just 
      // fetch the canonical encounter state to verify the data was saved.
      final dio = DioClient().dio;
      final response = await dio.get(ApiConstants.encounterCanonical(sessionId));
      
      final canonicalEncounter = CanonicalEncounter.fromJson(response.data);
      
      state = AsyncValue.data(canonicalEncounter.copyWith(
        status: 'finalized',
      ));
      
      return canonicalEncounter.canonicalId ?? canonicalEncounter.sessionId;
    } catch (e) {
      return null;
    }
  }
}
