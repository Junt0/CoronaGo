import 'package:hive/hive.dart';

class User{
  String username;
  String email;
  String password;
  String API_KEY;
 
  Map serializeFields(List<String> fieldNames) {
    Map parsedFieldMap = new Map();
    Map allFields = this._classFields();

    for (String name in fieldNames) {
      parsedFieldMap[name] = allFields[name];
    }
    
    return parsedFieldMap;
  }

  Map _classFields() {
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
  }

  void setEmail(String email) {
    this.email = email;
  }

  void setPassword(String password) {
    this.password = password;
  }

  // void storeAPIKey(String key) async {
  //   var box = await Hive.openBox('KEYS');
  //   await box.put('API_KEY', key);
  //   await box.close();

  //   this.API_KEY = key;
  // }

  // Future<String> loadAPIKey() async {
  //   var box = await Hive.openBox('KEYS');
  //   String key = await box.get('API_KEY');
  //   await box.close();

  //   this.API_KEY = key;
  //   return key;
  // }

  // Future<bool> hasAPIKey() async {
  //   await this.loadAPIKey();
  //   return this.API_KEY == null;
  // }
}