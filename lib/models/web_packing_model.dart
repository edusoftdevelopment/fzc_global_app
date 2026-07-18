// Models for the Web Invoice Scanner (packing) feature.
// JSON keys are PascalCase because they come from a .NET DataTable.

num _num(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? 0;
}

int _int(dynamic v) => _num(v).round();
double _dbl(dynamic v) => _num(v).toDouble();
String _str(dynamic v) => v?.toString() ?? '';

/// Generic write-response envelope.
class ApiResult {
  final bool success;
  final String error;
  ApiResult({required this.success, required this.error});
}

/// Screen 1 card — a Customer Invoice that flowed through
/// CustomerInvoice -> WebsiteCustomerInvoice -> WebsiteBoxInvoice.
class PackingInvoice {
  final int customerInvoiceId;
  final String invoiceNo;
  final String clubName;
  final int totalCustomers;
  final int totalItems;
  final double totalQty;
  final double packedQty;
  final int status; // 0 Pending, 1 In Progress, 2 Completed

  PackingInvoice({
    required this.customerInvoiceId,
    required this.invoiceNo,
    required this.clubName,
    required this.totalCustomers,
    required this.totalItems,
    required this.totalQty,
    required this.packedQty,
    required this.status,
  });

  double get remainingQty => (totalQty - packedQty).clamp(0, totalQty);
  int get progressPct =>
      totalQty > 0 ? ((packedQty / totalQty) * 100).round() : 0;

  String get statusText {
    switch (status) {
      case 2:
        return 'Completed';
      case 1:
        return 'In Progress';
      default:
        return 'Pending';
    }
  }

  factory PackingInvoice.fromJson(Map<String, dynamic> j) => PackingInvoice(
        customerInvoiceId: _int(j['CustomerInvoiceID']),
        invoiceNo: _str(j['InvoiceNo']),
        clubName: _str(j['ClubName']),
        totalCustomers: _int(j['TotalCustomers']),
        totalItems: _int(j['TotalItems']),
        totalQty: _dbl(j['TotalQty']),
        packedQty: _dbl(j['PackedQty']),
        status: _int(j['Status']),
      );
}

/// Screen 2 product row + Screen 3 scanned/found product.
class PackingProduct {
  final String itemCode;
  final String itemName;
  final String make;
  final double totalQty;
  final double packedQty;

  PackingProduct({
    required this.itemCode,
    required this.itemName,
    required this.make,
    required this.totalQty,
    required this.packedQty,
  });

  double get remainingQty => (totalQty - packedQty).clamp(0, totalQty);
  bool get isDone => remainingQty <= 0;

  factory PackingProduct.fromJson(Map<String, dynamic> j) => PackingProduct(
        itemCode: _str(j['ItemCode']),
        itemName: _str(j['ItemName']),
        make: _str(j['Make']),
        totalQty: _dbl(j['TotalQty']),
        packedQty: _dbl(j['PackedQty']),
      );
}

/// One physical box belonging to a customer (Option A: a scan may match any
/// of the customer's boxes).
class CustomerBox {
  final int boxId;
  final int websiteId;
  final String boxNo;
  final String barcode; // 12-digit CODE128

  CustomerBox({
    required this.boxId,
    required this.websiteId,
    required this.boxNo,
    required this.barcode,
  });

  factory CustomerBox.fromJson(Map<String, dynamic> j) => CustomerBox(
        boxId: _int(j['BoxID']),
        websiteId: _int(j['WebsiteID']),
        boxNo: _str(j['BoxNo']),
        barcode: _str(j['Barcode']),
      );
}

/// Screen 4 distribution row — one CUSTOMER (website order) the product goes
/// to, with the required qty and that customer's set of boxes.
class DistributionCustomer {
  final int websiteId;
  final String customerName;
  final int websiteDetailId;
  final int websiteCustomerInvoiceDetailId;
  final double requiredQty;
  final double packedQty;
  List<CustomerBox> boxes;

  DistributionCustomer({
    required this.websiteId,
    required this.customerName,
    required this.websiteDetailId,
    required this.websiteCustomerInvoiceDetailId,
    required this.requiredQty,
    required this.packedQty,
    this.boxes = const [],
  });

  double get remainingQty => (requiredQty - packedQty).clamp(0, requiredQty);
  bool get isDone => remainingQty <= 0;

  String get boxLabel => boxes.length == 1
      ? boxes.first.boxNo
      : (boxes.isEmpty ? '—' : '${boxes.length} boxes');

  /// Return the box whose barcode matches [scanned] (case-insensitive), or null.
  CustomerBox? matchBox(String scanned) {
    final s = scanned.trim().toUpperCase();
    for (final b in boxes) {
      if (b.barcode.trim().toUpperCase() == s ||
          b.boxNo.trim().toUpperCase() == s) {
        return b;
      }
    }
    return null;
  }

  factory DistributionCustomer.fromJson(Map<String, dynamic> j) =>
      DistributionCustomer(
        websiteId: _int(j['WebsiteID']),
        customerName: _str(j['CustomerName']),
        websiteDetailId: _int(j['WebsiteDetailID']),
        websiteCustomerInvoiceDetailId:
            _int(j['WebsiteCustomerInvoiceDetailID']),
        requiredQty: _dbl(j['RequiredQty']),
        packedQty: _dbl(j['PackedQty']),
      );
}

/// Result of a SavePacking call.
class PackResult {
  final bool success;
  final String error;
  final double packedQty;
  final double remainingQty;

  PackResult({
    required this.success,
    required this.error,
    required this.packedQty,
    required this.remainingQty,
  });

  factory PackResult.fromJson(Map<String, dynamic> j) => PackResult(
        success: j['success'] == true,
        error: j['error']?.toString() ?? '',
        packedQty: _dbl(j['PackedQty']),
        remainingQty: _dbl(j['RemainingQty']),
      );
}
