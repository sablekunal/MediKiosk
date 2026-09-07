import 'package:freezed_annotation/freezed_annotation.dart';

part 'intake_turn.freezed.dart';
part 'intake_turn.g.dart';

@freezed
abstract class IntakeTurnResponse with _$IntakeTurnResponse {
  const factory IntakeTurnResponse({
    @JsonKey(name: 'next_prompt') required String nextQuestion,
    @JsonKey(defaultValue: 'voice') required String expectedInputType, // Default to voice if not provided
    @JsonKey(name: 'next_slot') String? activeGrammar,
    @JsonKey(name: 'collected_slots') Map<String, dynamic>? slotFillingProgress,
    List<String>? options,
  }) = _IntakeTurnResponse;

  const IntakeTurnResponse._();

  factory IntakeTurnResponse.fromJson(Map<String, dynamic> json) => _$IntakeTurnResponseFromJson(json);
}
