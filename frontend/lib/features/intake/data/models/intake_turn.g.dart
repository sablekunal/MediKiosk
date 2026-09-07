// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intake_turn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IntakeTurnResponse _$IntakeTurnResponseFromJson(Map<String, dynamic> json) =>
    _IntakeTurnResponse(
      nextQuestion: json['next_prompt'] as String,
      expectedInputType: json['expectedInputType'] as String? ?? 'voice',
      activeGrammar: json['next_slot'] as String?,
      slotFillingProgress: json['collected_slots'] as Map<String, dynamic>?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$IntakeTurnResponseToJson(_IntakeTurnResponse instance) =>
    <String, dynamic>{
      'next_prompt': instance.nextQuestion,
      'expectedInputType': instance.expectedInputType,
      'next_slot': instance.activeGrammar,
      'collected_slots': instance.slotFillingProgress,
      'options': instance.options,
    };
