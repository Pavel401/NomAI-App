import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RemoteConfigService {
  RemoteConfigService({required FirebaseRemoteConfig remoteConfig})
      : _remoteConfig = remoteConfig;
  final FirebaseRemoteConfig _remoteConfig;

  // Base URL loaded from Remote Config
  static String _baseUrl = "";
  static RemoteConfigService? _instance;

  static Future<RemoteConfigService?> getInstance() async {
    if (_instance == null) {
      _instance = RemoteConfigService(
        remoteConfig: FirebaseRemoteConfig.instance,
      );
    }
    return _instance;
  }

  // Preferred getter for backend base URL
  static String getBaseUrl() {
    return _baseUrl;
  }

  // Backwards compatibility (temporary). Prefer getBaseUrl().
  @deprecated
  static String getImageProcessingBackendURL() {
    return _baseUrl;
  }

  Future initialise() async {
    try {
      await _fetchAndActivate();
    } on Exception catch (e) {
      print('Remote config fetch throttled: $e');
    } catch (e) {
      print(
          'Unable to fetch remote config. Cached or default values will be used..' +
              e.toString());
    }
  }

  Future _fetchAndActivate() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 20),
      minimumFetchInterval: const Duration(hours: 0),
    ));
    await _remoteConfig.ensureInitialized();
    await _remoteConfig.fetchAndActivate();

    // Try new key first, then fallback to legacy key
    final rcBase = _remoteConfig.getString("base_url");
    final legacy = _remoteConfig.getString("image_processing_url");
    _baseUrl = (rcBase.isNotEmpty ? rcBase : legacy).trim();
  }
}
