import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

@freezed
abstract class Patient with _$Patient {
  const factory Patient({
    String? name,
    int? age,
    String? gender,
    String? mobileNumber,
    String? abhaId,
  }) = _Patient;

  const Patient._();

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
}
