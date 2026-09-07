import 'package:flutter/foundation.dart';

class ApiConstants {
  // Allow overriding via compile-time flag: flutter run --dart-define=BASE_URL=http://...
  static const String _customBaseUrl = String.fromEnvironment('BASE_URL');

  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    
    // Web environment must target localhost or production
    if (kIsWeb) {
      return 'https://lneeas.zgrok.io/api/v1';
    }

    // Native target platforms
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'https://lneeas.zgrok.io/api/v1';
    }
  }

  // LLM inference with Qwen 2.5 can take >15s on slower local hardware
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const String sessionStart = '/intake/session/start';
  static String sessionTurn(String sessionId) => '/intake/session/$sessionId/turn';
  static String encounterCanonical(String sessionId) => '/encounter/$sessionId/canonical';
}
