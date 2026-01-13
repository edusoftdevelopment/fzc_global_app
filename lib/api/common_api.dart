import 'dart:convert';

import 'package:fzc_global_app/models/common_model.dart';
import 'package:fzc_global_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;

Future<List<DropDownItem>> getCustomers() async {
  try {
    final String url =
        await ApiHelper.buildUrl('/BarcodeAllotment/LoadCustomers');
    final response = await http
        .post(Uri.parse(url), headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((item) => DropDownItem.fromJson(item)).toList();
      } else {
        throw Exception(jsonResponse['error']);
      }
    } else {
      throw Exception('Failed to load customers: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load customers: $e');
  }
}

Future<List<DropDownItem>> getSuppliers() async {
  try {
    final String url =
        await ApiHelper.buildUrl('/BarcodeAllotment/LoadSuppliers');
    final response = await http
        .post(Uri.parse(url), headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((item) => DropDownItem.fromJson(item)).toList();
      } else {
        throw Exception(jsonResponse['error']);
      }
    } else {
      throw Exception('Failed to load suppliers: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load suppliers: $e');
  }
}

Future<List<DropDownItem>> getSupplierOrders(int supplierID) async {
  try {
    String queryParams = "";
    if (supplierID != 0) {
      queryParams += "?SupplierID=$supplierID";
    }

    final String url = await ApiHelper.buildUrl(
        '/BarcodeAllotment/LoadSupplierOrders$queryParams');
    final response = await http
        .post(Uri.parse(url), headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((item) => DropDownItem.fromJson(item)).toList();
      } else {
        throw Exception(jsonResponse['error']);
      }
    } else {
      throw Exception('Failed to load suppliers: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load suppliers: $e');
  }
}
