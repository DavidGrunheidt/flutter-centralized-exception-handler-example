import 'package:dio/dio.dart';

import 'app_constants.dart';

extension DioExceptionUtils on DioException {
  bool containsErrorCode(String errorCode) {
    try {
      final data = response?.data;
      return data != null && (data['detail']?['error'] as String).contains(errorCode);
    } catch (_) {
      return false;
    }
  }

  String get errorMessageDetail {
    try {
      return response?.data['detail']['error'];
    } catch (_) {
      return kGenericExceptionMessage;
    }
  }
}
