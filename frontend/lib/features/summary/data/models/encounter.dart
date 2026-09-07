import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../demographics/data/models/patient.dart';
import '../../../socrates/data/models/socrates_data.dart';
import '../../../ayurveda/data/models/ayurveda_data.dart';

part 'encounter.freezed.dart';
part 'encounter.g.dart';

@freezed
abstract class CanonicalEncounter with _$CanonicalEncounter {
  const factory CanonicalEncounter({
    @JsonKey(name: 'id') required String sessionId,
    required Patient patient,
    @JsonKey(name: 'socrates') required SocratesData westernTriage,
    @JsonKey(name: 'ayurveda') required AyurvedaData ayurvedicTriage,
    String? status,
    @JsonKey(readValue: _readCanonicalId) String? canonicalId,
    @JsonKey(name: 'started_at') DateTime? createdAt,
  }) = _CanonicalEncounter;

  factory CanonicalEncounter.fromJson(Map<String, dynamic> json) => _$CanonicalEncounterFromJson(json);
}

Object? _readCanonicalId(Map json, String key) => json['id'];
