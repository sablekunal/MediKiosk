import 'package:freezed_annotation/freezed_annotation.dart';

part 'turn_response.freezed.dart';
part 'turn_response.g.dart';

/// Mirrors the backend's `TurnResponse` schema exactly.
/// Every turn in the intake flow returns this object.
@freezed
abstract class TurnResponse with _$TurnResponse {
  const factory TurnResponse({
    @JsonKey(name: 'session_id') required String sessionId,
    required String stage,
    @JsonKey(name: 'completion_percent') required double completionPercent,
    @JsonKey(name: 'next_prompt') required String nextPrompt,
    @JsonKey(name: 'next_slot') String? nextSlot,
    @JsonKey(name: 'collected_slots') required Map<String, dynamic> collectedSlots,
    Map<String, dynamic>? extraction,
  }) = _TurnResponse;

  factory TurnResponse.fromJson(Map<String, dynamic> json) =>
      _$TurnResponseFromJson(json);
}
