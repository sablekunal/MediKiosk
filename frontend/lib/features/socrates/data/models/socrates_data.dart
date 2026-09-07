import 'package:freezed_annotation/freezed_annotation.dart';

part 'socrates_data.freezed.dart';
part 'socrates_data.g.dart';

@freezed
abstract class SocratesData with _$SocratesData {
  const factory SocratesData({
    String? site,
    String? onset,
    String? character,
    String? radiation,
    List<String>? associations,
    String? timeCourse,
    String? exacerbatingFactors,
    double? severity, // 0-10 VAS
  }) = _SocratesData;

  factory SocratesData.fromJson(Map<String, dynamic> json) => _$SocratesDataFromJson(json);
}
