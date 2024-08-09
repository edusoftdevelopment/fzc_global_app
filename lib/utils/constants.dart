import 'dart:ui';

class Constants {
  static const Color bgColor = Color.fromRGBO(250, 250, 250, 1);
  static const Color whiteColor = Color.fromRGBO(0, 0, 0, 1);

  // static const Color primaryColor = Color.fromRGBO(250, 204, 21, 1);
  static const Color primaryColor = Color.fromRGBO(234, 179, 8, 1);
  static const Color primaryColor200 = Color.fromRGBO(234, 179, 8, 0.7);

  static const Color secondaryColor = Color.fromRGBO(241, 245, 249, 1);
  static const Color dangerColor = Color(0xFFFF0000);
  static const Color accentColor = Color(0xFFFFC107);
}

class APIConstants {
  static const String baseUrl = 'https://foxhound-ace-wildly.ngrok-free.app';
}

class SecureStorageKeys {
  static const String userId = "userid";
  static const String username = "username";
  static const String email = "email";
  static const String customer = "CustomerID";
  static const String supplier = "SupplierID";
}
