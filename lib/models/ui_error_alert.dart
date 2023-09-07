import 'package:json_annotation/json_annotation.dart';

part 'ui_error_alert.g.dart';

@JsonSerializable()
class UIErrorAlert {
  const UIErrorAlert({
    required this.message,
    this.title,
    this.showOnSnackbar = false,
    this.showOnDialog = false,
    this.durationInSeconds = 3,
  });

  final String message;
  final String? title;
  final bool showOnSnackbar;
  final bool showOnDialog;
  final int durationInSeconds;

  factory UIErrorAlert.fromJson(Map<String, dynamic> json) => _$UIErrorAlertFromJson(json);

  Map<String, dynamic> toJson() => _$UIErrorAlertToJson(this);
}
