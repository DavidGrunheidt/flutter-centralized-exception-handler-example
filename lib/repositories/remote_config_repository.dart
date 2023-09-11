import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_centralized_exception_handler_example/helpers/remote_config_keys.dart';

import '../helpers/app_constants.dart';

class RemoteConfigRepository {
  final _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    try {
      if (!kIsWeb) _remoteConfig.onConfigUpdated.listen(updateConfigs, onError: (_) {});
      await _setDefaultConfigs();

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: kDebugMode ? const Duration(minutes: 1) : const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode ? const Duration(hours: 4) : const Duration(minutes: 1),
        ),
      );

      await _remoteConfig.fetchAndActivate();
    } catch (exception, stacktrace) {
      await FirebaseCrashlytics.instance.recordError(exception, stacktrace);
    } finally {
      await updateConfigs(RemoteConfigUpdate({}));
    }
  }

  String getErrorMessage(String errorCode) {
    final uiErrorAlertsRaw = _remoteConfig.getString(kUiErrorAlertsKey);
    final uiErrorAlertsMap = json.decode(uiErrorAlertsRaw) as Map<String, dynamic>;
    return uiErrorAlertsMap[errorCode];
  }

  Future<void> updateConfigs(RemoteConfigUpdate remoteConfigUpdate) => _remoteConfig.activate();

  Future<void> _setDefaultConfigs() async {
    final uiErrorAlerts = await rootBundle.loadString(uiErrorAlertsJsonPath);
    return _remoteConfig.setDefaults({kUiErrorAlertsKey: uiErrorAlerts});
  }
}
