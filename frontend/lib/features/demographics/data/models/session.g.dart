// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionResponse _$SessionResponseFromJson(Map<String, dynamic> json) =>
    _SessionResponse(
      sessionId: json['session_id'] as String,
      nextQuestion: json['next_prompt'] as String?,
      expectedInputType: json['expectedInputType'] as String? ?? 'text',
      slotFillingProgress: json['collected_slots'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SessionResponseToJson(_SessionResponse instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'next_prompt': instance.nextQuestion,
      'expectedInputType': instance.expectedInputType,
      'collected_slots': instance.slotFillingProgress,
    };
