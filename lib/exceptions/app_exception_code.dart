class AppExceptionCode implements Exception {
  const AppExceptionCode({
    required this.code,
  });

  final String code;
}
