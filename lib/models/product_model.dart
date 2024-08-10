import 'package:intl/intl.dart';

class ProductModel {
  String itemCode;
  String customerName;
  int customerID;
  int voucherID;
  int voucherDetailID;
  int saleOrderID;
  int saleOrderDetailID;
  String make;
  int quantity;
  String itemName;
  String barcode;
  double price;
  String type;
  int updatedQuantity;
  String supplierOrderNo;
  String orderNo;

  ProductModel({
    required this.itemCode,
    required this.customerName,
    required this.customerID,
    required this.voucherID,
    required this.voucherDetailID,
    required this.saleOrderID,
    required this.saleOrderDetailID,
    required this.make,
    required this.quantity,
    required this.itemName,
    required this.barcode,
    required this.price,
    required this.type,
    required this.updatedQuantity,
    required this.orderNo,
    required this.supplierOrderNo,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final numberFormat = NumberFormat.decimalPattern();

    return ProductModel(
      itemCode: json['ItemCode'] ?? "",
      customerName: json['CustomerName'] ?? "",
      customerID: numberFormat.parse(json['CustomerID'].toString()).toInt(),
      voucherID:
          numberFormat.parse(json['SupplierInvoiceID'].toString()).toInt(),
      voucherDetailID: numberFormat
          .parse(json['SupplierInvoiceDetailID'].toString())
          .toInt(),
      saleOrderID: numberFormat.parse(json['SaleOrderID'].toString()).toInt(),
      saleOrderDetailID:
          numberFormat.parse(json['SaleOrderDetailID'].toString()).toInt(),
      make: json['Make'] ?? "",
      quantity: numberFormat.parse(json['Quantity'].toString()).toInt(),
      itemName: json['ItemName'] ?? "",
      barcode: json['Barcode'] ?? "",
      price: numberFormat.parse(json['Price'].toString()).toDouble(),
      updatedQuantity: numberFormat.parse(json['Quantity'].toString()).toInt(),
      type: json['Type'] ?? "",
      orderNo: json['OrderNo'] ?? "",
      supplierOrderNo: json['SupplierOrderNo'] ?? "",
    );
  }

  Map<String, dynamic> toJson(
      String barCode, int updatedQuantity, String from) {
    return {
      'BarcodeAllotmentID': 0,
      'ItemCode': itemCode,
      'CustomerID': customerID,
      'VoucherID': voucherID,
      'VoucherDetailID': voucherDetailID,
      'SaleOrderID': saleOrderID,
      'SaleOrderDetailID': saleOrderDetailID,
      'Quantity': quantity,
      'Make': make,
      'Barcode': barCode,
      'UpdatedQuantity': updatedQuantity,
      'Type': type,
      'From': from,
    };
  }
}
