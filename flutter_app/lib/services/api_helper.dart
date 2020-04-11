import 'package:flutter_app/models/auth_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// TODO comment api helper
class APIHelper {
  static const String domain = "http://192.168.0.19:8000/";
  static Map<String, String> urlSuffixes = {
    'signup': 'api/auth/signup/',
    'get_token': 'api/auth/',
    'join_interaction': 'api/interaction/join/',
    'create_interaction': 'api/interaction/create/',
    'end_interaction': 'api/interaction/end/',
  };
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
    return "$domain${urlSuffixes[ending]}";
  }

  String getErrorMessage(http.Response response) {
    return this.getResponseAttribute(response, "error");
  }

  Map responseToMap(http.Response response) {
    return jsonDecode(response.body);
  }

  String getResponseAttribute(http.Response response, String attribute) {
    Map decoded = this.responseToMap(response);
    bool hasAttribute = decoded.containsKey(attribute);
    return hasAttribute ? decoded[attribute] : null;
  }
}

class APIAuth {
  AuthUser user;
  APIHelper helper;
  bool authenticated = false;

  APIAuth(AuthUser user) {
    this.user = user;
    this.helper = new APIHelper();
    this.user.loadAPIKey();
  }

  Future<bool> signup(AuthUser user) async {
    http.Response response =
        await this._signupRequest(user.getUsername(), user.getPassword(), user.getEmail());
    return this.helper.requestSuccessful(response);
  }

  Future<http.Response> _signupRequest(String username, password, email) async {
    Map requestBody =
        this.user.attributesToMap(['username', 'password', 'email']);

    try {
      http.Response response =
          await http.post(helper.getURL("signup"), body: requestBody);
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<bool> login(AuthUser user) async {
    bool hasKey = await user.hasAPIKey();
    bool loggedIn = false;

    if (!hasKey) {
      print("Sending login request");
      if (!this.user.isNull(['username', 'password'])) {
        http.Response response = await this._sendTokenRequest();
        if (this.helper.requestSuccessful(response)) {
          String key = this.helper.getResponseAttribute(response, "token");
          user.storeAPIKey(key);

          loggedIn = true;
        }
      }
    } else {
      print("Already logged in");
      loggedIn = true;
    }

    this.authenticated = loggedIn;
    return this.authenticated;
  }

  Future<http.Response> _sendTokenRequest() async {
    Map requestBody = this.user.attributesToMap(['username', 'password']);

    try {
      http.Response response =
          await http.post(helper.getURL("get_token"), body: requestBody);
      return response;
    } catch (e) {
      return null;
    }
  }

  void logout() {
    user.clearHive();
    user = new AuthUser();
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
