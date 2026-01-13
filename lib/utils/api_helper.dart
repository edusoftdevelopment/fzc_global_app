import 'package:fzc_global_app/utils/secure_storage.dart';
import 'package:fzc_global_app/utils/constants.dart';

class ApiHelper {
  static final SecureStorage _secureStorage = SecureStorage();

  // Get the current base URL (either saved or default)
  static Future<String> getBaseUrl() async {
    final savedUrl =
        await _secureStorage.readSecureData(SecureStorageKeys.baseUrl);
    return savedUrl ?? APIConstants.baseUrl;
  }

  // Build full API endpoint URL
  static Future<String> buildUrl(String endpoint) async {
    final baseUrl = await getBaseUrl();
    // Remove trailing slash from baseUrl and leading slash from endpoint if exists
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$cleanBaseUrl$cleanEndpoint';
  }
}
