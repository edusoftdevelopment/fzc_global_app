import 'dart:convert';

import 'package:fzc_global_app/models/box_dispatched_status_model.dart';
import 'package:fzc_global_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BoxDispatchedStatusApi {
  static const String endpoint = '/BoxDispatchStatus/GetDeliveryModes';

  /// Fetches delivery modes and returns the parsed [DeliveryModes] model.
  static Future<DeliveryModes> getDeliveryModes() async {
    try {
      final String url = await ApiHelper.buildUrl(endpoint);
      final response = await http.post(Uri.parse(url), headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return DeliveryModes.fromJson(jsonResponse);
        } else {
          throw Exception(jsonResponse['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception(
            'Failed to load delivery modes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load delivery modes: $e');
    }
  }

  static Future<CustomersModel> getCustomers() async {
    try {
      final String url =
          await ApiHelper.buildUrl('/BarcodeAllotment/LoadCustomers');
      final response = await http.post(Uri.parse(url), headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return CustomersModel.fromJson(jsonResponse);
        } else {
          throw Exception(jsonResponse['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to load Customers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load Customer: $e');
    }
  }

  /// Fetch box data using filters. Matches POST /BoxDispatchStatus/GetBoxData
  static Future<BoxData> getBoxData({
    required String type,
    String? datefrom,
    String? dateto,
    int deliveryModelID = 0,
    int customerID = 0,
  }) async {
    try {
      final String baseUrl =
          await ApiHelper.buildUrl('/BoxDispatchStatus/GetBoxData');

      // backend requires NON-EMPTY dates
      final String safeDateFrom = (datefrom != null && datefrom.isNotEmpty)
          ? datefrom
          : DateFormat('dd-MMM-yyyy').format(DateTime.now());

      final String safeDateTo = (dateto != null && dateto.isNotEmpty)
          ? dateto
          : DateFormat('dd-MMM-yyyy').format(DateTime.now());

      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'Type': type,
        'datefrom': safeDateFrom,
        'dateto': safeDateTo,
        'DeliveryModeID': deliveryModelID.toString(),
        'CustomerID': customerID.toString(),
      });

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return BoxData.fromJson({
          'dt': jsonResponse['data'] ?? [],
        });
      } else {
        throw Exception('Failed to load box data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load box data: $e');
    }
  }

  // static Future<BoxData> getBoxData({
  //   required String type,
  //   String? datefrom,
  //   String? dateto,
  //   int deliveryModelID = 0,
  //   int customerID = 0,
  // }) async {
  //   try {
  //     final String url =
  //         await ApiHelper.buildUrl('/BoxDispatchStatus/GetBoxData');

  //     final payload = {
  //       "Type": type,
  //       "datefrom": datefrom ?? '',
  //       "dateto": dateto ?? '',
  //       "DeliveryModeID": deliveryModelID,
  //       "CustomerID": customerID,
  //     };

  //     final response = await http.post(Uri.parse(url),
  //         headers: {"Content-Type": "application/json"},
  //         body: json.encode(payload));

  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       if (jsonResponse['dt'] != null) {
  //         return BoxData.fromJson(jsonResponse);
  //       } else {
  //         return BoxData.fromJson({"dt": []});
  //       }
  //     } else {
  //       throw Exception('Failed to load box data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to load box data: $e');
  //   }
  // }
}
