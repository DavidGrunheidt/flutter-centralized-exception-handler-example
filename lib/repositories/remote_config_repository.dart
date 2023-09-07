import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../helpers/app_constants.dart';
import '../helpers/remote_config_keys.dart';
import '../models/ui_error_alert.dart';

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

  Future<void> updateConfigs(RemoteConfigUpdate remoteConfigUpdate) => _remoteConfig.activate();

  Map<String, UIErrorAlert> get uiErrorAlerts {
    final uiErrorAlertJson = _remoteConfig.getString(kUiErrorAlertsKey);
    final uiErrorAlertMap = json.decode(uiErrorAlertJson) as Map<String, dynamic>;
    return uiErrorAlertMap.map((key, value) => MapEntry(key, UIErrorAlert.fromJson(value)));
  }

  Future<void> _setDefaultConfigs() async {
    final uiErrorAlerts = await rootBundle.loadString(uiErrorAlertsJsonPath);

    return _remoteConfig.setDefaults({
      kUiErrorAlertsKey: uiErrorAlerts,
    });
  }
}
