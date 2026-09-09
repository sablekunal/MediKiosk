import 'package:flutter/foundation.dart';

class ApiConstants {
  // Allow overriding via compile-time flag: flutter run --dart-define=BASE_URL=http://...
  static const String _customBaseUrl = String.fromEnvironment('BASE_URL');

  /// Dynamic server URL override (can be changed at runtime in app settings)
  static String? runtimeBaseUrl;

  static String get baseUrl {
    if (runtimeBaseUrl != null && runtimeBaseUrl!.isNotEmpty) {
      return runtimeBaseUrl!;
    }
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    
    // Web environment targets local compute box
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }

    // Native target platforms
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api/v1';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'http://127.0.0.1:8000/api/v1';
    }
  }

  // LLM inference with Qwen 2.5 can take >15s on slower local hardware
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const String sessionStart = '/intake/session/start';
  static String sessionTurn(String sessionId) => '/intake/session/$sessionId/turn';
  static String encounterCanonical(String sessionId) => '/encounter/$sessionId/canonical';
  static String encounterFhir(String sessionId) => '/encounter/$sessionId/fhir';

  // Media inference
  static const String mediaTranscribe = '/media/transcribe';
  static const String mediaSynthesize = '/media/synthesize';
  static const String mediaOcr       = '/media/ocr';

  // Health
  static const String health = '/health';
}
