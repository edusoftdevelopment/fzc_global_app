import 'package:flutter/foundation.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class ConfigurationProvider with ChangeNotifier {
  final SecureStorage _secureStorage = SecureStorage();

  String _baseUrl = APIConstants.baseUrl;

  String get baseUrl => _baseUrl;

  // Load base URL from storage when app starts
  Future<void> loadBaseUrl() async {
    final savedUrl =
        await _secureStorage.readSecureData(SecureStorageKeys.baseUrl);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _baseUrl = savedUrl;
      notifyListeners();
    }
  }

  // Save base URL to storage
  Future<void> saveBaseUrl(String url) async {
    await _secureStorage.writeSecureData(SecureStorageKeys.baseUrl, url);
    _baseUrl = url;
    notifyListeners();
  }

  // Reset to default URL
  Future<void> resetToDefault() async {
    await _secureStorage.deleteSecureData(SecureStorageKeys.baseUrl);
    _baseUrl = APIConstants.baseUrl;
    notifyListeners();
  }
}
