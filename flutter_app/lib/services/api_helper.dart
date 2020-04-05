import 'package:flutter_app/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// TODO comment api helper
class APIHelper {
  static const String domain = "http://192.168.0.19:8000/";
  static Map<String, String> endings = {
    'signup': 'api/auth/signup',
    'get_token': 'api/auth',
    'join_interaction': 'api/interaction/join',
    'create_interaction': 'api/interaction/create',
    'end_interaction': 'api/interaction/end',
  };

  Future<bool> signup(User user) async {
    http.Response response =
        await this._signupRequest(user.username, user.password, user.email);

    try {
      this._throwProperAPIException(response);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Depending on the status code it will throw an exception with the proper error message
  void _throwProperAPIException(http.Response response) {
    if (response == null) {
      throw APIConnectionError();
    }

    String serverErrorMsg = this.getErrorMessage(response);
    int statusFirstDig = (response.statusCode / 100).floor();

    if (statusFirstDig == 4) {
      throw APIAuthError(serverErrorMsg);
    } else if (statusFirstDig == 5) {
      throw APIServerError(serverErrorMsg);
    }
  }

  Future<http.Response> _signupRequest(String username, password, email) async {
    Map<String, String> requestBody = {
      'username': username,
      'password': password,
      'email': email,
    };

    try {
      http.Response response =
          await http.post(this.getURL("signup"), body: requestBody);
      return response;
    } catch (e) {
      return null;
    }
  }

  String getURL(String ending) {
    return "$domain${endings[ending]}/";
  }

  String getErrorMessage(http.Response response) {
    dynamic decoded = jsonDecode(response.body);
    String error = "";
    if (decoded.containsKey("error")) {
      error = decoded['error'];
    }

    return error;
  }
}

class APIConnectionError implements Exception {
  String errorMessage() {
    return 'The API refused to connect';
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
