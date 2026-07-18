class BarcodeManager {
  BarcodeManager._();

  static String? parseBarcode(String barcode) {
    try {
      String parsedBarcode = "";
      var splittedArr = barcode.split(" ");
      // Keep letters, digits AND the dash, only stripping spaces / stray chars
      // like "$". The server stores data_BarcodeInfo.Barcode WITH the dash,
      // truncated to 12 chars (e.g. "19322-PNA-003" -> "19322-PNA-00"), and
      // matches it exactly, so the dash must be preserved here.
      var cleanedBarcode =
          splittedArr[0].replaceAll(RegExp(r'[^A-Za-z0-9-]'), '');
      parsedBarcode = cleanedBarcode;
      if (cleanedBarcode.length > 12) {
        parsedBarcode = cleanedBarcode.substring(0, 12);
      }

      return parsedBarcode;
    } catch (e) {
      return null;
    }
  }

  /// Removes spaces and stray characters (e.g. the "$" currency/control
  /// artifact from Code 39 labels) but KEEPS the dash, WITHOUT truncating the
  /// length. Use for box barcodes that may be longer than 12 characters.
  static String sanitizeBarcode(String barcode) {
    try {
      final firstToken = barcode.split(" ")[0];
      return firstToken.replaceAll(RegExp(r'[^A-Za-z0-9-]'), '');
    } catch (e) {
      return barcode;
    }
  }
}
