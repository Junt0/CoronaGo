import 'package:hive/hive.dart';

class User {
  String username;
  String email;
  String password;
  String API_KEY;

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
      'username': username,
      'email': email,
      'password': password,
      'API_KEY': API_KEY,
    };

    return fields;
  }

  void setUsername(String username) {
    this.username = username;
    this.saveToHive(field: "username");
  }

  void setEmail(String email) {
    this.email = email;
    this.saveToHive(field: "email");
  }

  void setPassword(String password) {
    this.password = password;
    this.saveToHive(field: "password");
  }

  void storeAPIKey(String key) async {
    this.API_KEY = key;
    this.saveToHive(field: "API_KEY");
  }

  Future<String> loadAPIKey() async {
    var box = Hive.box('USER');
    String key = box.get('API_KEY');

    this.API_KEY = key;
    return key;
  }

  Future<bool> hasAPIKey() async {
    await this.loadAPIKey();
    return this.API_KEY != null;
  }

  static User loadFromHive() {
    Box userBox = Hive.box('USER');
    User blankUser = new User();

    blankUser.username = userBox.get("username");
    blankUser.email = userBox.get("email");
    blankUser.password = userBox.get("password");
    blankUser.API_KEY = userBox.get("API_KEY");

    return blankUser;
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
