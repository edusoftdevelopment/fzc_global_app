import 'dart:convert';

import 'package:fzc_global_app/models/common_model.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:http/http.dart' as http;

Future<List<DropDownItem>> getCustomers() async {
  try {
    final response = await http.post(
        Uri.parse('${APIConstants.baseUrl}/BarcodeAllotment/LoadCustomers'),
        headers: {"Content-Type": "application/json"});

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
    final response = await http.post(
        Uri.parse('${APIConstants.baseUrl}/BarcodeAllotment/LoadSuppliers'),
        headers: {"Content-Type": "application/json"});

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

    final response = await http.post(
        Uri.parse(
            '${APIConstants.baseUrl}/BarcodeAllotment/LoadSupplierOrders$queryParams'),
        headers: {"Content-Type": "application/json"});

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
