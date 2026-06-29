import 'dart:convert';

import 'package:fzc_global_app/models/sales_location_model.dart';
import 'package:fzc_global_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;

class SalesLocationApi {
  /// Pending supplier orders (have a sale voucher + still need a location update).
  static Future<List<PendingOrder>> getPendingOrders({
    String? dateFrom,
    String? dateTo,
    String? search,
  }) async {
    final base = await ApiHelper.buildUrl('/SalesLocation/GetPendingOrders');
    final uri = Uri.parse(base).replace(queryParameters: {
      if (dateFrom != null && dateFrom.isNotEmpty) 'DateFrom': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'DateTo': dateTo,
      if (search != null && search.isNotEmpty) 'Search': search,
    });
    final res =
        await http.post(uri, headers: {"Content-Type": "application/json"});
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      final List data = (j['data'] as List?) ?? [];
      return data
          .map((e) => PendingOrder.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load pending orders: ${res.statusCode}');
  }

  /// Pending lines for one supplier order, with each line's available
  /// locations and any allocations already saved.
  static Future<List<OrderLine>> getOrderLines(int supplierOrderId) async {
    final base = await ApiHelper.buildUrl('/SalesLocation/GetOrderLines');
    final uri = Uri.parse(base).replace(
        queryParameters: {'SupplierOrderID': supplierOrderId.toString()});
    final res =
        await http.post(uri, headers: {"Content-Type": "application/json"});
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      final lines = ((j['lines'] as List?) ?? [])
          .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
          .toList();
      final locations = ((j['locations'] as List?) ?? [])
          .map((e) => LocationOption.fromJson(e as Map<String, dynamic>))
          .toList();
      final allocations = ((j['allocations'] as List?) ?? [])
          .map((e) => Allocation.fromJson(e as Map<String, dynamic>))
          .toList();
      for (final l in lines) {
        l.locations = locations
            .where((x) => x.saleVoucherDetailId == l.saleVoucherDetailId)
            .toList();
        l.allocations = allocations
            .where((x) => x.saleVoucherDetailId == l.saleVoucherDetailId)
            .toList();
        l.recompute();
      }
      return lines;
    }
    throw Exception('Failed to load order lines: ${res.statusCode}');
  }

  /// Save (insert/update) the full set of picks for one line. The backend SP
  /// replaces all existing rows for the line, so pass the COMPLETE set.
  static Future<ApiResult> saveLocation({
    required int saleVoucherId,
    required int saleVoucherDetailId,
    required List<Map<String, int>> picks,
  }) async {
    final url = await ApiHelper.buildUrl('/SalesLocation/SaveLocation');
    final body = json.encode({
      'SaleVoucherID': saleVoucherId,
      'SaleVoucherDetailID': saleVoucherDetailId,
      'Picks': picks
          .map((p) => {
                'StockLocationID': p['StockLocationID'],
                'SaleQuantity': p['SaleQuantity'],
              })
          .toList(),
    });
    final res = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: body,
    );
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      return ApiResult(
        success: j['success'] == true,
        error: j['error']?.toString() ?? '',
      );
    }
    throw Exception('Failed to save location: ${res.statusCode}');
  }
}
