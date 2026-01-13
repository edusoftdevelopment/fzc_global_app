import 'dart:convert';

import 'package:fzc_global_app/models/box_dispatched_status_model.dart';
import 'package:fzc_global_app/models/common_model.dart';
import 'package:fzc_global_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;

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
}
