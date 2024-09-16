import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class ApiKeyProvider with ChangeNotifier {
  String _apiKey = '';

  String get apiKey => _apiKey;

  Future<void> fetchApiKey() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    await remoteConfig.fetchAndActivate();
    _apiKey = remoteConfig.getString('google_maps_api_key');
    notifyListeners();
  }
}
