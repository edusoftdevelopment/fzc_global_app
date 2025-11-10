class BarcodeManager {
  BarcodeManager._();

  static String? parseBarcode(String barcode) {
    try {
      String parsedBarcode = "";
      var splittedArr = barcode.split(" ");
      var barcodeWithoutSpaces = splittedArr[0].replaceAll(" ", "");
      parsedBarcode = barcodeWithoutSpaces;
      if (barcodeWithoutSpaces.length > 12) {
        parsedBarcode = barcodeWithoutSpaces.substring(0, 12);
      }

      return parsedBarcode;
    } catch (e) {
      return null;
    }
  }
}
