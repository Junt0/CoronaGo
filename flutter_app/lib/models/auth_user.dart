import 'package:hive/hive.dart';

class AuthUser {
  String _username;
  String _email;
  String _password;
  String _API_KEY;
  Box hive = Hive.box('USER');

  AuthUser();

  String getUsername() => _username;
  String getEmail() => _username;
  String getPassword() => _username;

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
    this.saveToHive(field: "password");
  }

  void setAPIKey(String key) async {
    this._API_KEY = key;
    this.saveToHive(field: "API_KEY");
  }

  Map attributesToMap(List<String> attributeNames) {
    Map parsedFieldMap = new Map();
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

  AuthUser.loadFromHive() {
    _username = hive.get("username");
    _email = hive.get("email");
    _password = hive.get("password");
    _API_KEY = hive.get("API_KEY");
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
