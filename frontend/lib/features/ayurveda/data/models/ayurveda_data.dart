import 'package:freezed_annotation/freezed_annotation.dart';

part 'ayurveda_data.freezed.dart';
part 'ayurveda_data.g.dart';

@freezed
abstract class AyurvedaData with _$AyurvedaData {
  const factory AyurvedaData({
    String? agni,
    String? koshtha,
    String? ahara,
    String? vihara,
    String? nidra,
  }) = _AyurvedaData;

  factory AyurvedaData.fromJson(Map<String, dynamic> json) => _$AyurvedaDataFromJson(json);
}
