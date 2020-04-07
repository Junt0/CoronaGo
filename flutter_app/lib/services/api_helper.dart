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
  User user;

  APIHelper(this.user);

  bool requestSuccessful(http.Response response) {
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
    // If there is no response from the server
    if (response == null) {
      throw APIConnectionError();
    }

    String serverErrorMsg = this.getErrorMessage(response);
    int statusNearestHundreth = (response.statusCode / 100).floor() * 100;

    // TODO make exception for 300 code
    Map<int, Object> httpErrorCode = {
      500: APIServerError(serverErrorMsg),
      400: APIAuthError(serverErrorMsg),
      300: null,
      200: null,
      null: null,
    };

    Exception error = httpErrorCode[statusNearestHundreth];
    if (error != null) {
      throw error;
    }
  }

  String getURL(String ending) {
    return "$domain${endings[ending]}/";
  }

  String getErrorMessage(http.Response response) {
    return this.getResponseAttribute(response, "error");
  }

  String getResponseAttribute(http.Response response, String attribute) {
    dynamic decoded = jsonDecode(response.body);
    bool hasAttribute = decoded.containsKey(attribute);
    return hasAttribute ? decoded[attribute] : null;
  }
}

class APIAuth {
  User user;
  APIHelper helper;
  bool authenticated = false;

  APIAuth(User user) {
    this.user = user;
    this.helper = new APIHelper(this.user);
  }

  Future<bool> signup(User user) async {
    http.Response response =
        await this._signupRequest(user.username, user.password, user.email);
  }

  Future<http.Response> _signupRequest(String username, password, email) async {
    Map requestBody =
        this.user.serializeFields(['username', 'password', 'email']);

    try {
      http.Response response =
          await http.post(helper.getURL("signup"), body: requestBody);
      return response;
    } catch (e) {
      return null;
    }
  }

  // Future<bool> login(User user) async {
  //   bool hasKey = await user.hasAPIKey();
  //   if (!hasKey) {
  //     http.Response response = await this._sendTokenRequest();
  //     if (this.helper.requestSuccessful(response)) {
  //       user.storeAPIKey(key)
  //     }
  //   }
  // }

  // Future<http.Response> _sendTokenRequest() async {
  //   Map requestBody = this.user.serializeFields(['username', 'password']);

  //   try {
  //     http.Response response =
  //         await http.post(helper.getURL("get_token"), body: requestBody);
  //     return response;
  //   } catch (e) {
  //     return null;
  //   }
  // }

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
