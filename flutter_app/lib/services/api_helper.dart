import 'package:flutter_app/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
class APIHelper {
  static const String domain = "http://127.0.0.1:8000/";
  static Map<String, String> endings = {
    'signup': 'api/auth/signup',
    'get_token': 'api/auth/',
    'join_interaction': 'api/interaction/join',
    'create_interaction': 'api/interaction/create',
    'end_interaction': 'api/interaction/end',
  };

  void signup(User user) async {
    http.Response response = await this._signupRequest(user.username, user.password, user.email);
    
    Exception exception = this._getAPIException(response);
    if (exception != null) {
      throw exception;
    }
  }

  Exception _getAPIException(http.Response response) {
    String serverErrorMsg = this.getErrorMessage(response);
    int statusFirstDig = (response.statusCode / 100).floor();

    if (statusFirstDig == 4) {
      return APIAuthError(serverErrorMsg);
    } else if (statusFirstDig == 5) {
      return APIServerError(serverErrorMsg);
    } else {
      return null;
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
    }

    return error;
  }


}


class APIInvalidRequest implements Exception {
  String message;

  APIInvalidRequest([this.message]);

  String errorMessage() {
    return 'An invalid request was sent by the app: $message';
  }
}

class APIAuthError implements Exception {
  String message;

  APIAuthError([this.message]);

  String errorMessage() {
    return 'Authentication error with the API: $message';
  }
}

class APIServerError implements Exception {
  String message;

  APIServerError([this.message]);

  String errorMessage() {
    return 'An unknown error has occured with the server: $message';
  }
}