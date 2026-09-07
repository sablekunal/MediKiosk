import 'package:audioplayers/audioplayers.dart';

class AudioFeedbackService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playGuidance(String text) async {
    // In a production app, this would integrate with a TTS engine 
    // or play a pre-recorded asset mapped to the backend question ID.
    // For now, we simulate UI feedback.
    await _player.play(AssetSource('audio/guidance_chime.mp3'));
  }

  Future<void> playSuccess() async {
    await _player.play(AssetSource('audio/success.mp3'));
  }

  void dispose() {
    _player.dispose();
  }
}
