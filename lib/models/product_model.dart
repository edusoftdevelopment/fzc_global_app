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

  ProductModel(
      {required this.itemCode,
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
      required this.supplierOrderNo});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      itemCode: json['ItemCode'],
      customerName: json['CustomerName'],
      customerID: json['CustomerID'],
      voucherID: json['SupplierInvoiceID'],
      voucherDetailID: json['SupplierInvoiceDetailID'],
      saleOrderID: json['SaleOrderID'],
      saleOrderDetailID: json['SaleOrderDetailID'],
      make: json['Make'],
      quantity: int.parse(json['Quantity'].toString().replaceAll(".", "")),
      itemName: json['ItemName'],
      barcode: json['Barcode'],
      price: double.parse(json['Price'].toString()),
      updatedQuantity:
          int.parse(json['Quantity'].toString().replaceAll(".", "")),
      type: json['Type'],
      orderNo: json['OrderNo'],
      supplierOrderNo: json['SupplierOrderNo'],
    );
  }

  Map<String, dynamic> toJson(String barCode, int updatedQuantity) {
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
      'Type': type
    };
  }
}
