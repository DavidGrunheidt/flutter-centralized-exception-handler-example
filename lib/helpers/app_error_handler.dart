import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_centralized_exception_handler_example/helpers/app_constants.dart';
import 'package:flutter_centralized_exception_handler_example/helpers/dio_utils.dart';

import '../dependencies/error_handler_context_locator.dart';
import '../dependencies/repository_locator.dart';
import '../design_system/ui_alerts.dart';
import '../exceptions/app_exception_code.dart';
import '../models/crashlytics_error_status_enum.dart';
import '../models/ui_error_alert.dart';
import '../repositories/remote_config_repository.dart';
import 'app_exception_codes.dart';

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

  // TODO(DavidGrunheidt): report image loading issue to error reporting server.
  //  if (error is NetworkImageLoadException)

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
        final uiErrorAlerts = repositoryLocator<RemoteConfigRepository>().uiErrorAlerts;
        final errorCode = uiErrorAlerts.keys.firstWhere((code) => error.containsErrorCode('[$code]'));
        return handleUiErrorAlert(uiErrorAlert: uiErrorAlerts[errorCode]!);
    }
  } catch (_) {
    return handleUiErrorAlert(
      uiErrorAlert: UIErrorAlert(message: error.errorMessageDetail, showOnSnackbar: true),
    );
  }
}

void handleAppExceptionCode({
  required String code,
}) {
  try {
    final uiErrorAlerts = repositoryLocator<RemoteConfigRepository>().uiErrorAlerts;
    return handleUiErrorAlert(uiErrorAlert: uiErrorAlerts[code]!);
  } catch (_) {
    return handleUiErrorAlert(
      uiErrorAlert: const UIErrorAlert(message: kGenericExceptionMessage, showOnSnackbar: true),
    );
  }
}

void handleUiErrorAlert({
  required UIErrorAlert uiErrorAlert,
}) {
  final context = getErrorHandlerContext();

  if (uiErrorAlert.showOnSnackbar) {
    return showSnackbar(
      context: context,
      content: '${uiErrorAlert.title == null ? '' : '${uiErrorAlert.title}. '}${uiErrorAlert.message}',
    );
  } else if (uiErrorAlert.showOnDialog) {
    showAppDialog(
      context: context,
      title: uiErrorAlert.title,
      content: Text(uiErrorAlert.message),
    );
  }
}
