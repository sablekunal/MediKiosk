import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@freezed
abstract class SessionResponse with _$SessionResponse {
  const factory SessionResponse({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'next_prompt') String? nextQuestion,
    @JsonKey(defaultValue: 'text') String? expectedInputType,
    @JsonKey(name: 'collected_slots') Map<String, dynamic>? slotFillingProgress,
  }) = _SessionResponse;

  const SessionResponse._();

  factory SessionResponse.fromJson(Map<String, dynamic> json) => _$SessionResponseFromJson(json);
}
