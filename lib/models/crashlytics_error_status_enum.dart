enum CrashlyticsErrorStatusEnum {
  fatal,
  nonFatal,
  dontReport,
}

extension CrahslyticsErrorStatusEnumExtension on CrashlyticsErrorStatusEnum {
  bool get isFatal => this == CrashlyticsErrorStatusEnum.fatal;

  bool get shouldNotReport => this == CrashlyticsErrorStatusEnum.dontReport;
}
