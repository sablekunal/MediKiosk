import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'language_provider.g.dart';

class Language {
  final String code;
  final String nativeLabel;
  const Language(this.code, this.nativeLabel);
}

const supportedLanguages = [
  Language('en', 'English'),
  Language('hi', 'हिंदी (Hindi)'),
];

@riverpod
class LanguageController extends _$LanguageController {
  @override
  String build() => 'en';

  void setLanguage(String code) => state = code;
}

