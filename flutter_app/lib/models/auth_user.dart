import 'package:hive/hive.dart';

class AuthUser{
  String _username;
  String _email;
  String _password;
  String _API_KEY;

  AuthUser();

  String getUsername() => _username;
  String getEmail() => _username;
  String getPassword() => _username;
  
  String getAPIKey({bool load = false}) {
    if (load)
      this.loadAPIKey();
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
    var box = Hive.box('USER');
    String key = box.get('API_KEY');

    this._API_KEY = key;
    return key;
  }

  Future<bool> hasAPIKey() async {
    await this.loadAPIKey();
    return this._API_KEY != null;
  }

  AuthUser.loadFromHive() {
    Box userBox = Hive.box('USER');

    _username = userBox.get("username");
    _email = userBox.get("email");
    _password = userBox.get("password");
    _API_KEY = userBox.get("API_KEY");
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
    Box userBox = Hive.box('USER');
    Map fields = this._classAttributes();

    if (field == "all") {
      for (var item in fields.keys) {
        userBox.put(item, fields[item]);
      }
    } else {
      userBox.put(field, fields[field]);
    }
  }

  void clearHive() async {
    var box = Hive.box('USER');
    box.clear();
  }
}
