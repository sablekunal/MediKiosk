// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socrates_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocratesData _$SocratesDataFromJson(Map<String, dynamic> json) =>
    _SocratesData(
      site: json['site'] as String?,
      onset: json['onset'] as String?,
      character: json['character'] as String?,
      radiation: json['radiation'] as String?,
      associations: (json['associations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      timeCourse: json['timeCourse'] as String?,
      exacerbatingFactors: json['exacerbatingFactors'] as String?,
      severity: (json['severity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SocratesDataToJson(_SocratesData instance) =>
    <String, dynamic>{
      'site': instance.site,
      'onset': instance.onset,
      'character': instance.character,
      'radiation': instance.radiation,
      'associations': instance.associations,
      'timeCourse': instance.timeCourse,
      'exacerbatingFactors': instance.exacerbatingFactors,
      'severity': instance.severity,
    };
