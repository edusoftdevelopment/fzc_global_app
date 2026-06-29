// Models for the "Update Sales Location" feature.
// Numbers come from a .NET DataTable (may be int, double, or string) -> parse safely.

num _num(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? 0;
}

int _int(dynamic v) => _num(v).round();

String _str(dynamic v) => v?.toString() ?? '';

class ApiResult {
  final bool success;
  final String error;
  ApiResult({required this.success, required this.error});
}

/// A supplier order that has a sale voucher and still needs location update.
class PendingOrder {
  final int supplierOrderId;
  final String orderNo;
  final String voucherDate;
  final String supplierName;
  final String customerName;
  final int pendingLines;
  final int pendingQty;

  PendingOrder({
    required this.supplierOrderId,
    required this.orderNo,
    required this.voucherDate,
    required this.supplierName,
    required this.customerName,
    required this.pendingLines,
    required this.pendingQty,
  });

  factory PendingOrder.fromJson(Map<String, dynamic> j) => PendingOrder(
        supplierOrderId: _int(j['SupplierOrderID']),
        orderNo: _str(j['OrderNo']),
        voucherDate: _str(j['VoucherDate']),
        supplierName: _str(j['SupplierName']),
        customerName: _str(j['CustomerName']),
        pendingLines: _int(j['PendingLines']),
        pendingQty: _int(j['PendingQty']),
      );
}

/// A bin (stock location) that holds available stock for a line's item.
class LocationOption {
  final int saleVoucherDetailId;
  final int stockLocationId;
  final String stockLocationTitle;
  final String barcode;
  final int availableQty;

  LocationOption({
    required this.saleVoucherDetailId,
    required this.stockLocationId,
    required this.stockLocationTitle,
    required this.barcode,
    required this.availableQty,
  });

  factory LocationOption.fromJson(Map<String, dynamic> j) => LocationOption(
        saleVoucherDetailId: _int(j['SaleVoucherDetailID']),
        stockLocationId: _int(j['StockLocationID']),
        stockLocationTitle: _str(j['StockLocationTitle']),
        barcode: _str(j['Barcode']),
        availableQty: _int(j['AvailableQty']),
      );
}

/// An already-saved location allocation for a line.
class Allocation {
  final int saleVoucherDetailId;
  final int stockLocationId;
  final String stockLocationTitle;
  final String barcode;
  int saleQuantity;

  Allocation({
    required this.saleVoucherDetailId,
    required this.stockLocationId,
    required this.stockLocationTitle,
    required this.barcode,
    required this.saleQuantity,
  });

  factory Allocation.fromJson(Map<String, dynamic> j) => Allocation(
        saleVoucherDetailId: _int(j['SaleVoucherDetailID']),
        stockLocationId: _int(j['StockLocationID']),
        stockLocationTitle: _str(j['StockLocationTitle']),
        barcode: _str(j['Barcode']),
        saleQuantity: _int(j['SaleQuantity']),
      );
}

/// A pending sale-voucher line within an order.
class OrderLine {
  final int saleVoucherDetailId;
  final int saleVoucherId;
  final String itemCode;
  final String brand;
  final String itemName;
  final int orderQty;
  int allocatedQty;
  int remainingQty;
  final int totalStock;
  List<LocationOption> locations;
  List<Allocation> allocations;

  OrderLine({
    required this.saleVoucherDetailId,
    required this.saleVoucherId,
    required this.itemCode,
    required this.brand,
    required this.itemName,
    required this.orderQty,
    required this.allocatedQty,
    required this.remainingQty,
    required this.totalStock,
    this.locations = const [],
    this.allocations = const [],
  });

  factory OrderLine.fromJson(Map<String, dynamic> j) => OrderLine(
        saleVoucherDetailId: _int(j['SaleVoucherDetailID']),
        saleVoucherId: _int(j['SaleVoucherID']),
        itemCode: _str(j['ItemCode']),
        brand: _str(j['Brand']),
        itemName: _str(j['ItemName']),
        orderQty: _int(j['OrderQty']),
        allocatedQty: _int(j['AllocatedQty']),
        remainingQty: _int(j['RemainingQty']),
        totalStock: _int(j['TotalStock']),
        locations: const [],
        allocations: const [],
      );

  /// recompute allocated/remaining from the current allocations list
  void recompute() {
    allocatedQty = allocations.fold(0, (s, a) => s + a.saleQuantity);
    remainingQty = orderQty - allocatedQty;
  }
}
