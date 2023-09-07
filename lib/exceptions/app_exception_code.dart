import 'package:json_annotation/json_annotation.dart';

part 'app_exception_code.g.dart';

@JsonSerializable()
class AppExceptionCode implements Exception {
  const AppExceptionCode({
    required this.code,
  });

  final String code;

  factory AppExceptionCode.fromJson(Map<String, dynamic> json) => _$AppExceptionCodeFromJson(json);

  Map<String, dynamic> toJson() => _$AppExceptionCodeToJson(this);
}
