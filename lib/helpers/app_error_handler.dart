import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../dependencies/error_handler_context_locator.dart';
import '../dependencies/repository_locator.dart';
import '../design_system/ui_alerts.dart';
import '../exceptions/app_exception_code.dart';
import '../models/crashlytics_error_status_enum.dart';
import '../repositories/remote_config_repository.dart';
import 'app_constants.dart';
import 'app_exception_codes.dart';
import 'dio_utils.dart';

CrashlyticsErrorStatusEnum getCrashlyticsErrorStatus(Object error) {
  if (error is AppExceptionCode) return CrashlyticsErrorStatusEnum.dontReport;
  if (error is DioException) {
    final nonFatalTypes = [DioExceptionType.connectionTimeout, DioExceptionType.connectionError];
    final isNonFatal = nonFatalTypes.contains(error.type);
    return isNonFatal ? CrashlyticsErrorStatusEnum.nonFatal : CrashlyticsErrorStatusEnum.dontReport;
  }

  return CrashlyticsErrorStatusEnum.fatal;
}

void reportErrorDetails(FlutterErrorDetails flutterErrorDetails) {
  const errors = <String>['rendering library', 'widgets library'];

  final isSilentOnRelease = kReleaseMode && flutterErrorDetails.silent;
  final isLibraryOnDebug = !kReleaseMode && errors.contains(flutterErrorDetails.library);
  if (isSilentOnRelease || isLibraryOnDebug) {
    log(
      flutterErrorDetails.exceptionAsString(),
      name: 'ReportErrorDetails',
      stackTrace: flutterErrorDetails.stack,
      error: flutterErrorDetails.exception,
    );
  }

  return reportErrorToUI(flutterErrorDetails.exception, flutterErrorDetails.stack);
}

void reportErrorToUI(Object error, StackTrace? stackTrace) {
  if (error is DioException) return handleDioException(error);
  if (error is AppExceptionCode) return handleAppExceptionCode(code: error.code);

  return handleAppExceptionCode(code: kGenericErrorKey);
}

void handleDioException(DioException error) {
  try {
    switch (error.type) {
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionTimeout:
        return handleAppExceptionCode(code: kDioTimeoutErrorKey);
      case DioExceptionType.unknown:
        return handleAppExceptionCode(code: kCheckInternetConnectionErrorKey);
      default:
        final errorMsg = error.errorMessageDetail;
        final codeRaw = kBracketsContentRegex.allMatches(errorMsg).first.group(0)!;
        final code = codeRaw.substring(1, codeRaw.length - 1);

        return handleAppExceptionCode(code: code, fallbackMsg: error.errorMessageDetail);
    }
  } catch (_) {
    return showErrorMessage(error.errorMessageDetail);
  }
}

void handleAppExceptionCode({
  required String code,
  String fallbackMsg = kGenericExceptionMessage,
}) {
  try {
    final message = repositoryLocator<RemoteConfigRepository>().getString(code);
    return showErrorMessage(message.isEmpty ? fallbackMsg : message);
  } catch (_) {
    return showErrorMessage(fallbackMsg);
  }
}

void showErrorMessage(String message) {
  final context = getErrorHandlerContext();
  return showSnackbar(context: context, content: message);
}
