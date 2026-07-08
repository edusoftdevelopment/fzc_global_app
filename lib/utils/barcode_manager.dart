class BarcodeManager {
  BarcodeManager._();

  static String? parseBarcode(String barcode) {
    try {
      String parsedBarcode = "";
      var splittedArr = barcode.split(" ");
      // Strip everything except letters and digits (removes spaces, "$", "-", etc.)
      var cleanedBarcode =
          splittedArr[0].replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
      parsedBarcode = cleanedBarcode;
      if (cleanedBarcode.length > 12) {
        parsedBarcode = cleanedBarcode.substring(0, 12);
      }

      return parsedBarcode;
    } catch (e) {
      return null;
    }
  }

  /// Removes spaces and any non-alphanumeric characters (e.g. the "$"
  /// currency/control artifact from Code 39 labels) WITHOUT truncating the
  /// length. Use for box barcodes that may be longer than 12 characters.
  static String sanitizeBarcode(String barcode) {
    try {
      final firstToken = barcode.split(" ")[0];
      return firstToken.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    } catch (e) {
      return barcode;
    }
  }
}
