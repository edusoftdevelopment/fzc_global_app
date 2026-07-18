import 'dart:convert';

import 'package:fzc_global_app/models/web_packing_model.dart';
import 'package:fzc_global_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;

/// API layer for the Web Invoice Scanner (packing) feature.
/// Hits the new /WebPacking controller on RateListManagementWebsiteAPI.
class WebPackingApi {
  static const _jsonHeader = {"Content-Type": "application/json"};

  /// Screen 1 — Customer Invoices that flowed through
  /// CustomerInvoice -> WebsiteCustomerInvoice -> WebsiteBoxInvoice.
  static Future<List<PackingInvoice>> getPendingInvoices({
    String? search,
    String? dateFrom,
    String? dateTo,
  }) async {
    final base = await ApiHelper.buildUrl('/WebPacking/GetPendingInvoices');
    final uri = Uri.parse(base).replace(queryParameters: {
      if (search != null && search.isNotEmpty) 'Search': search,
      if (dateFrom != null && dateFrom.isNotEmpty) 'DateFrom': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'DateTo': dateTo,
    });
    final res = await http.post(uri, headers: _jsonHeader);
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      final List data = (j['data'] as List?) ?? [];
      return data
          .map((e) => PackingInvoice.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load invoices: ${res.statusCode}');
  }

  /// Screen 2 — distinct product lines for a customer invoice, with packed qty.
  static Future<List<PackingProduct>> getInvoiceProducts(
      int customerInvoiceId) async {
    final base = await ApiHelper.buildUrl('/WebPacking/GetInvoiceProducts');
    final uri = Uri.parse(base).replace(queryParameters: {
      'CustomerInvoiceID': customerInvoiceId.toString(),
    });
    final res = await http.post(uri, headers: _jsonHeader);
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      final List data = (j['data'] as List?) ?? [];
      return data
          .map((e) => PackingProduct.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load products: ${res.statusCode}');
  }

  /// Screen 3 — resolve a scanned barcode or typed item code to a product line.
  /// Returns null if not part of this invoice.
  static Future<PackingProduct?> findProduct({
    required int customerInvoiceId,
    required String code,
  }) async {
    final base = await ApiHelper.buildUrl('/WebPacking/FindProduct');
    final uri = Uri.parse(base).replace(queryParameters: {
      'CustomerInvoiceID': customerInvoiceId.toString(),
      'Code': code,
    });
    final res = await http.post(uri, headers: _jsonHeader);
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      if (j['success'] != true) return null;
      final List data = (j['data'] as List?) ?? [];
      if (data.isEmpty) return null;
      return PackingProduct.fromJson(data.first as Map<String, dynamic>);
    }
    throw Exception('Failed to find product: ${res.statusCode}');
  }

  /// Screen 4 — customers the product is distributed across, each with its
  /// boxes attached (a scan may match any of the customer's boxes).
  static Future<List<DistributionCustomer>> getProductDistribution({
    required int customerInvoiceId,
    required String itemCode,
  }) async {
    final base = await ApiHelper.buildUrl('/WebPacking/GetProductDistribution');
    final uri = Uri.parse(base).replace(queryParameters: {
      'CustomerInvoiceID': customerInvoiceId.toString(),
      'ItemCode': itemCode,
    });
    final res = await http.post(uri, headers: _jsonHeader);
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      final customers = ((j['customers'] as List?) ?? [])
          .map((e) => DistributionCustomer.fromJson(e as Map<String, dynamic>))
          .toList();
      final boxes = ((j['boxes'] as List?) ?? [])
          .map((e) => CustomerBox.fromJson(e as Map<String, dynamic>))
          .toList();
      for (final c in customers) {
        c.boxes =
            boxes.where((b) => b.websiteId == c.websiteId).toList();
      }
      return customers;
    }
    throw Exception('Failed to load distribution: ${res.statusCode}');
  }

  /// Screen 6/7 — save a pack. The server re-validates the scanned barcode
  /// against the box and clamps qty to remaining.
  static Future<PackResult> savePacking({
    required int customerInvoiceId,
    required int boxId,
    required String itemCode,
    required int websiteDetailId,
    required int websiteCustomerInvoiceDetailId,
    required int qty,
    required String scannedBarcode,
    int? loginId,
  }) async {
    final url = await ApiHelper.buildUrl('/WebPacking/SavePacking');
    final body = json.encode({
      'CustomerInvoiceID': customerInvoiceId,
      'BoxID': boxId,
      'ItemCode': itemCode,
      'WebsiteDetailID': websiteDetailId,
      'WebsiteCustomerInvoiceDetailID': websiteCustomerInvoiceDetailId,
      'Qty': qty,
      'ScannedBarcode': scannedBarcode,
      'LoginId': loginId,
    });
    final res = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: body,
    );
    if (res.statusCode == 200) {
      return PackResult.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to save packing: ${res.statusCode}');
  }
}
