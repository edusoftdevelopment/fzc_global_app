import 'dart:convert';
import 'package:fzc_global_app/models/user_model.dart';
import 'package:fzc_global_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;

Future<UserModel> loginUser(String identifier, String password) async {
  if (identifier.isNotEmpty && password.isNotEmpty) {
    final String url = await ApiHelper.buildUrl('/Login/LoginProcess');

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            "Content-Type": "application/json; charset=UTF-8"
          },
          body: jsonEncode(
              <String, String>{'UserName': identifier, 'Password': password}));

      Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['success'] == true) {
        var responseBody = jsonDecode(response.body);
        UserModel user = UserModel.fromJson(responseBody);
        return user;
      } else {
        throw Exception("${responseBody['error']}");
      }
    } catch (e) {
      throw Exception("$e");
    }
  } else {
    throw Exception("Please provice username and password!");
  }
}
