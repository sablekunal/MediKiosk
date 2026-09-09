import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import '../services/media_service.dart';

class AudioState {
  final bool isRecording;
  final bool isTranscribing;
  final bool isPlayingTts;
  final String? lastTranscript;
  final String? errorMessage;

  const AudioState({
    this.isRecording = false,
    this.isTranscribing = false,
    this.isPlayingTts = false,
    this.lastTranscript,
    this.errorMessage,
  });

  AudioState copyWith({
    bool? isRecording,
    bool? isTranscribing,
    bool? isPlayingTts,
    String? lastTranscript,
    String? errorMessage,
  }) {
    return AudioState(
      isRecording: isRecording ?? this.isRecording,
      isTranscribing: isTranscribing ?? this.isTranscribing,
      isPlayingTts: isPlayingTts ?? this.isPlayingTts,
      lastTranscript: lastTranscript ?? this.lastTranscript,
      errorMessage: errorMessage,
    );
  }
}

class AudioController extends Notifier<AudioState> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  @override
  AudioState build() {
    _player.onPlayerStateChanged.listen((playerState) {
      if (playerState == PlayerState.completed || playerState == PlayerState.stopped) {
        state = state.copyWith(isPlayingTts: false);
      }
    });

    ref.onDispose(() {
      _recorder.dispose();
      _player.dispose();
    });

    return const AudioState();
  }

  /// Start recording voice input from microphone
  Future<void> startRecording() async {
    try {
      if (state.isPlayingTts) {
        await stopTts();
      }

      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        state = state.copyWith(errorMessage: 'Microphone permission not granted.');
        return;
      }

      await _recorder.start(
        RecordConfig(
          encoder: kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc,
        ),
        path: '',
      );
      state = state.copyWith(isRecording: true, errorMessage: null);
    } catch (e) {
      state = state.copyWith(isRecording: false, errorMessage: 'Failed to start recording: $e');
    }
  }

  /// Stop recording and transcribe audio via backend Whisper service
  Future<String?> stopRecordingAndTranscribe({String? language}) async {
    if (!state.isRecording) return null;

    try {
      state = state.copyWith(isRecording: false, isTranscribing: true, errorMessage: null);
      final path = await _recorder.stop();

      Uint8List? audioBytes;
      String filename = 'recording.webm';

      if (path != null && path.isNotEmpty) {
        if (kIsWeb) {
          // On Web, path is a blob URL; fetch bytes with a clean Dio instance
          try {
            final resp = await Dio().get<List<int>>(
              path,
              options: Options(responseType: ResponseType.bytes),
            );
            if (resp.data != null) {
              audioBytes = Uint8List.fromList(resp.data!);
              filename = 'recording.webm';
            }
          } catch (e) {
            debugPrint('Failed to read web blob: $e');
          }
        } else {
          // Native / Android / Desktop
          final file = File(path);
          if (await file.exists()) {
            audioBytes = await file.readAsBytes();
            filename = 'recording.m4a';
          }
        }
      }

      if (audioBytes != null && audioBytes.isNotEmpty) {
        final result = await MediaService.instance.transcribe(
          audioBytes,
          filename: filename,
          language: language,
        );
        state = state.copyWith(
          isTranscribing: false,
          lastTranscript: result.text,
          errorMessage: result.errorMessage,
        );
        return result.text;
      }

      state = state.copyWith(isTranscribing: false);
      return null;
    } catch (e) {
      state = state.copyWith(isTranscribing: false, errorMessage: 'Transcription failed: $e');
      return null;
    }
  }

  /// Synthesize text to speech using Piper backend TTS and play it
  Future<void> playTts(String text, {String language = 'en'}) async {
    try {
      if (state.isRecording) return;
      if (state.isPlayingTts) {
        await stopTts();
        return;
      }

      state = state.copyWith(isPlayingTts: true, errorMessage: null);
      final wavBytes = await MediaService.instance.synthesize(text, language: language);

      if (wavBytes.length <= 44) {
        // Backend TTS produced silence/unavailable; complete cleanly without error
        state = state.copyWith(isPlayingTts: false);
        return;
      }

      // Play audio bytes using BytesSource
      await _player.stop();
      await _player.play(BytesSource(wavBytes));
    } catch (e) {
      state = state.copyWith(isPlayingTts: false);
    }
  }

  Future<void> stopTts() async {
    try {
      await _player.stop();
    } catch (_) {}
    state = state.copyWith(isPlayingTts: false);
  }
}

final audioControllerProvider = NotifierProvider<AudioController, AudioState>(() {
  return AudioController();
});
