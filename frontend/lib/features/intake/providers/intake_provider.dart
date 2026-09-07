import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../data/models/intake_turn.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../demographics/providers/demographics_provider.dart';

part 'intake_provider.g.dart';

@riverpod
class IntakeController extends _$IntakeController {
  final AudioRecorder _recorder = AudioRecorder();

  @override
  AsyncValue<IntakeTurnResponse?> build() {
    final sessionData = ref.watch(sessionControllerProvider).value;
    if (sessionData != null && sessionData.nextQuestion != null) {
      return AsyncValue.data(IntakeTurnResponse(
        nextQuestion: sessionData.nextQuestion!,
        expectedInputType: sessionData.expectedInputType ?? 'voice',
        slotFillingProgress: sessionData.slotFillingProgress,
      ));
    }
    return const AsyncValue.data(null);
  }

  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/intake_voice.m4a';
      
      // Check if already recording
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }

      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    }
  }

  Future<void> stopAndSubmitRecording() async {
    final path = await _recorder.stop();
    if (path != null) {
      await submitTurn(audioPath: path);
    }
  }

  Future<void> submitTurn({String? text, String? audioPath, String? selectedOption}) async {
    final sessionId = ref.read(sessionControllerProvider).value?.sessionId;
    if (sessionId == null) return;

    state = const AsyncValue.loading();
    try {
      final dio = DioClient().dio;
      dynamic data;

      if (audioPath != null) {
        final file = File(audioPath);
        data = FormData.fromMap({
          'audio': await MultipartFile.fromFile(file.path, filename: 'turn_audio.m4a'),
        });
      } else {
        data = {
          'transcript': text ?? '',
          'selected_value': selectedOption,
        };
      }

      final response = await dio.post(
        ApiConstants.sessionTurn(sessionId),
        data: data,
      );
      
      state = AsyncValue.data(IntakeTurnResponse.fromJson(response.data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void dispose() {
    _recorder.dispose();
  }
}
