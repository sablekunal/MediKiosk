// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turn_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TurnResponse _$TurnResponseFromJson(Map<String, dynamic> json) =>
    _TurnResponse(
      sessionId: json['session_id'] as String,
      stage: json['stage'] as String,
      completionPercent: (json['completion_percent'] as num).toDouble(),
      nextPrompt: json['next_prompt'] as String,
      nextSlot: json['next_slot'] as String?,
      collectedSlots: json['collected_slots'] as Map<String, dynamic>,
      extraction: json['extraction'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TurnResponseToJson(_TurnResponse instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'stage': instance.stage,
      'completion_percent': instance.completionPercent,
      'next_prompt': instance.nextPrompt,
      'next_slot': instance.nextSlot,
      'collected_slots': instance.collectedSlots,
      'extraction': instance.extraction,
    };
