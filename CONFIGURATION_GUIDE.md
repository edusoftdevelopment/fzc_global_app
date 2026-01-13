# Configuration System - Usage Guide

## Overview

The app now supports dynamic API base URL configuration that can be changed from the settings screen.

## What Was Updated

### 1. Constants (`lib/utils/constants.dart`)

- Added `baseUrl` key to `SecureStorageKeys`

### 2. Configuration Provider (`lib/providers/configuration_provider.dart`)

- New provider to manage base URL state
- Auto-loads saved URL on app start
- Methods: `loadBaseUrl()`, `saveBaseUrl()`, `resetToDefault()`

### 3. Configuration Screen (`lib/pages/settings/screens/configuration_screen.dart`)

- Completely rewritten to work with Provider package
- Simple UI to change base URL
- Validates URL format (must start with http:// or https://)
- Shows current active URL
- Reset to default button
- Integrates with your app's theme (Constants.bgColor, primaryColor, etc.)

### 4. Main App (`lib/main.dart`)

- Added `ConfigurationProvider` to MultiProvider
- Added route: `/settings/configuration`

### 5. API Helper (`lib/utils/api_helper.dart`)

- Utility class to get dynamic base URL
- `ApiHelper.getBaseUrl()` - Get current base URL
- `ApiHelper.buildUrl(endpoint)` - Build complete URL

## How to Use

### Access Configuration Screen

Navigate to the configuration screen:

```dart
Navigator.pushNamed(context, '/settings/configuration');
```

### Update Your API Calls

You have two options:

#### Option 1: Using ApiHelper (Recommended)

```dart
import 'package:fzc_global_app/utils/api_helper.dart';

Future<UserModel> loginUser(String identifier, String password) async {
  if (identifier.isNotEmpty && password.isNotEmpty) {
    // Use ApiHelper to get dynamic URL
    final String url = await ApiHelper.buildUrl('/Login/LoginProcess');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8"
        },
        body: jsonEncode(<String, String>{
          'UserName': identifier,
          'Password': password
        })
      );
      // ... rest of your code
    } catch (e) {
      throw Exception("$e");
    }
  }
}
```

#### Option 2: Using Provider Directly

```dart
import 'package:provider/provider.dart';
import 'package:fzc_global_app/providers/configuration_provider.dart';

// In your widget:
Widget build(BuildContext context) {
  final configProvider = Provider.of<ConfigurationProvider>(context);
  final baseUrl = configProvider.baseUrl;

  // Use baseUrl in your API calls
  final url = '$baseUrl/Login/LoginProcess';
}
```

### Add Settings Button to Your UI

In your user account page or settings page:

```dart
ListTile(
  leading: Icon(Icons.settings, color: Constants.primaryColor),
  title: Text('API Configuration'),
  subtitle: Text('Change server URL'),
  onTap: () {
    Navigator.pushNamed(context, '/settings/configuration');
  },
)
```

Or as a button:

```dart
ElevatedButton.icon(
  onPressed: () {
    Navigator.pushNamed(context, '/settings/configuration');
  },
  icon: Icon(Icons.settings),
  label: Text('Configuration'),
)
```

## Features

✅ **Dynamic URL Change**: Change base URL without rebuilding the app
✅ **Persistent Storage**: URL saved in secure storage
✅ **Default Fallback**: Falls back to `APIConstants.baseUrl` if nothing saved
✅ **Reset Option**: One-click reset to default URL
✅ **URL Validation**: Ensures URL starts with http:// or https://
✅ **Real-time Updates**: Provider notifies all listeners when URL changes
✅ **Copy Support**: Click to copy current URL to clipboard

## Default URL

Default URL is defined in `lib/utils/constants.dart`:

```dart
static const String baseUrl = 'http://92.99.173.190:112';
```

## Testing

1. Run the app
2. Navigate to: `/settings/configuration`
3. Enter a new base URL
4. Click "Save Configuration"
5. The new URL will be used for all API calls

## Migration Guide for Existing API Calls

### Before:

```dart
const String url = "${APIConstants.baseUrl}/endpoint";
```

### After:

```dart
final String url = await ApiHelper.buildUrl('/endpoint');
```

That's it! The system will automatically use the configured URL or fall back to the default.
