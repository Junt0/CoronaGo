import 'package:http/http.dart' as http;
import 'dart:convert';

class APIHelper {
  static const String domain = "http://127.0.0.1:8000/";
  static Map<String, String> endings = {
    'signup': 'api/auth/signup',
    'get_token': 'api/auth/',
    'join_interaction': 'api/interaction/join',
    'create_interaction': 'api/interaction/create',
    'end_interaction': 'api/interaction/end',
  };

  void signup(String username, password, email) async {
    http.Response response = await this._signupRequest(username, password, email);
    if (response.statusCode != 200) {
      throw Exception(this.getErrorMessage(response));
    }
  }

  Future<http.Response> _signupRequest(String username, password, email) async {
    Map<String, String> requestBody = {
      'username': username,
      'password': password,
      'email': email,
    };
    http.Response response = await http.post(this.getUrlBase("signup"), body: requestBody);
    return response;
  }

  String getUrlBase(String ending) {
    return "$domain${endings[ending]}/";
  }

  String getErrorMessage(http.Response response) {
    dynamic decoded = jsonDecode(response.body);
    String error = "";
    if (decoded.hasKey("error")) {
      error = decoded['error'];
    } else {
      error = "An unknown error has occurred";
    }

    return error;
  }


}
