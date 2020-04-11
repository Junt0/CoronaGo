import 'package:hive/hive.dart';

class AuthUser {
  String _username;
  String _email;
  String _password;
  String _API_KEY;
  Box hive;

  AuthUser() {
    this._initHive();
  }

  AuthUser.testing(Box mockBox) {
    this.hive = mockBox;
  }

  AuthUser.fromHive() {
    this._initHive();
    this.loadFromHive();
  }

  void loadFromHive() {
    _username = hive.get("username");
    _email = hive.get("email");
    _API_KEY = hive.get("API_KEY");
  }

  void _initHive() {
    Hive.openBox('USER');
    hive = Hive.box('USER');
  }

  String getUsername() => _username;
  String getEmail() => _email;
  String getPassword() => _password;

  String getAPIKey({bool load = false}) {
    if (load) this.loadAPIKey();
    return this._API_KEY;
  }

  void setUsername(String username) {
    this._username = username;
    this.saveToHive(field: "username");
  }

  void setEmail(String email) {
    this._email = email;
    this.saveToHive(field: "email");
  }

  void setPassword(String password) {
    this._password = password;
  }

  void setAPIKey(String key) async {
    this._API_KEY = key;
    this.saveToHive(field: "API_KEY");
  }

  Map<String, dynamic> attributesToMap(List<String> attributeNames) {
    Map<String, dynamic> parsedFieldMap = new Map();
    Map allFields = this._classAttributes();

    for (String name in attributeNames) {
      parsedFieldMap[name] = allFields[name];
    }

    return parsedFieldMap;
  }

  Map _classAttributes() {
    var fields = {
      'username': _username,
      'email': _email,
      'password': _password,
      'API_KEY': _API_KEY,
    };

    return fields;
  }

  Future<String> loadAPIKey() async {
    String key = hive.get('API_KEY');

    this._API_KEY = key;
    return key;
  }

  Future<bool> hasAPIKey() async {
    await this.loadAPIKey();
    return this._API_KEY != null;
  }

  bool isNull(List<String> attributes) {
    Map fields = this._classAttributes();

    for (var attr in attributes) {
      if (fields[attr] == null) {
        return true;
      }
    }
    return false;
  }

  void saveToHive({field = "all"}) {
    Map fields = this._classAttributes();

    if (field == 'password')
      return null;
    
    if (field == "all") {
      for (var item in fields.keys) {
        hive.put(item, fields[item]);
      }
    } else {
      hive.put(field, fields[field]);
    }
  }

  void clearHive() async {
    hive.clear();
  }
}
