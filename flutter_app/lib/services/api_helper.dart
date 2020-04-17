import 'dart:io';

import 'package:flutter_app/models/auth_user.dart';
import 'package:flutter_app/models/interaction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// TODO comment api helper
class APIHelper {
  static const String address = "0.0.0.0"; //192.168.0.19
  static const int port = 8000;
  static const String scheme = 'http'; // PRODUCTION TODO make https request instead of http in production!!!!!
  http.Client client = new http.Client();

  static Map<String, String> unencodedPath = {
    'signup': 'api/auth/signup/',
    'get_token': 'api/auth/',
    'join_interaction': 'api/interaction/join/',
    'create_interaction': 'api/interaction/create/',
    'end_interaction': 'api/interaction/end/',
  };

  bool requestSuccessful(http.Response response) {
    try {
      this.throwProperAPIException(response);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Depending on the status code it will throw an exception with the proper error message
  void throwProperAPIException(http.Response response) {
    // If there is no response from the server
    if (response == null) {
      throw APIConnectionError();
    }

    String serverResponse = this.serverDetailResponse(response);
    int statusNearestHundreth = (response.statusCode / 100).floor() * 100;

    Map<int, Object> httpErrorCode = {
      500: APIServerError(serverResponse),
      400: APIAuthError(serverResponse),
      300: null,
      200: null,
      null: null,
    };

    Exception error = httpErrorCode[statusNearestHundreth];
    if (error != null) {
      throw error;
    }
  }

  // Returns a url
  String getURL(String ending) {
    String scheme = "${APIHelper.scheme}://";
    String address = APIHelper.address;
    String port = "";
    String path = "/${unencodedPath[ending]}";

    //Puts the port into the string if it is available
    if (APIHelper.port != null) {
      port = ":${APIHelper.port.toString()}";
    }

    return scheme + address + port + path;
  }

  static String getPath(String name) {
    return unencodedPath[name];
  }

  String serverDetailResponse(http.Response response) {
    return this.getResponseAttribute(response, "detail");
  }

  Map responseToMap(http.Response response) {
    return jsonDecode(response.body);
  }

  dynamic getResponseAttribute(http.Response response, String attribute) {
    Map decoded = this.responseToMap(response);
    bool hasAttribute = decoded.containsKey(attribute);
    return hasAttribute ? decoded[attribute] : null;
  }

  http.Request createRequest(String method, String path, {Map body, Map headers}) {
    if (body == null) body = {};
    if (headers == null) headers = {};

    http.Request unauthenticatedRequest = new http.Request(
      method,
      Uri(
        host: APIHelper.address,
        path: path,
        port: APIHelper.port,
        scheme: APIHelper.scheme,
      ),
    );

    unauthenticatedRequest.body = json.encode(body);
    for (String key in headers.keys) {
      unauthenticatedRequest.headers[key] = headers[key];
    }
    return unauthenticatedRequest;
  }

  Future<http.Response> sendRequest(http.Request request) async {
    http.StreamedResponse streamedResponse = await this.client.send(request);
    return await http.Response.fromStream(streamedResponse);
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

  Future<bool> signup() async {
    http.Response response = await this._signupRequest(
        user.getUsername(), user.getPassword(), user.getEmail());
    return this.helper.requestSuccessful(response);
  }

  Future<http.Response> _signupRequest(String username, password, email) async {
    Map requestBody = this.user.attributesToMap(['username', 'password', 'email']);
    http.Request signupRequest = this.helper.createRequest("post", APIHelper.getPath("signup"), body: requestBody);
    
    try {
      http.Response response = await this.helper.sendRequest(signupRequest);
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<bool> login() async {
    bool hasKey = await user.hasAPIKey();
    bool loggedIn = false;

    if (!hasKey) {
      print("Sending login request");
      if (!this.user.isNull(['username', 'password'])) {
        http.Response response = await this._sendTokenRequest();
        if (this.helper.requestSuccessful(response)) {
          String key = this.helper.getResponseAttribute(response, "token");
          user.setAPIKey(key);

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
    http.Request loginRequest = this.helper.createRequest("post", APIHelper.getPath("login"), body: requestBody);
    try {
      http.Response response = await this.helper.sendRequest(loginRequest);
      return response;
    } catch (e) {
      return null;
    }
  }

  void logout() {
    user.clearHive();
    user = new AuthUser();
  }

  http.Request authenticatedRequest(String method, String path) {
    http.Request request = this.helper.createRequest(method, path);
    request = this.makeRequestAuthenticated(request);
    return request;
  }

  http.Request makeRequestAuthenticated(http.Request request) {
    request.headers['Authorization'] = 'Token ${this.user.getAPIKey()}';
    return request;
  }
}

class InteractionEndpoints extends APIAuth {
  InteractionEndpoints(AuthUser user) : super(user);

  Future<Interaction> join(String uuid) async {
    http.Response response = await this._joinRequest(uuid);
    if (this.helper.requestSuccessful(response)) {
      return Interaction.fromResponse(this.helper.responseToMap(response)); 
    } else {
      return null;
    }
  }

  Future<http.Response> _joinRequest(String uuid) async {
    String path = APIHelper.getPath("join_interaction") + "$uuid/";
    http.Request joinRequest = this.helper.createRequest("get", path);
    try {
      return await this.helper.sendRequest(joinRequest);
    } catch (e) {
      return null;
    }
  }

  Future<Interaction> create() async {
    http.Response response = await this._createRequest();
    if (this.helper.requestSuccessful(response)) {
      return Interaction.fromResponse(this.helper.responseToMap(response)); 
    } else {
      return null;
    }
  }

  Future<http.Response> _createRequest() async {
    String path = APIHelper.getPath("create_interaction");
    http.Request joinRequest = this.helper.createRequest("get", path);
    try {
      return await this.helper.sendRequest(joinRequest);
    } catch (e) {
      return null;
    }
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
