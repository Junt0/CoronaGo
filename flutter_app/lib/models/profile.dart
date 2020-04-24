import 'package:flutter_app/services/caching.dart';

class Profile extends CachedClass {
  String key;
  double _risk;
  String _email = "";
  String _username;

  Profile();

  Profile.fromJson(Map<String, dynamic> parsedJson) {
    _risk = double.parse(parsedJson['risk']);
    _email = parsedJson['user']['email'];
    _username = parsedJson['user']['username'];
  }

  Map<String, dynamic> toCacheFormat({bool excludeKey = true}) {
    List excludedAttributes = (excludeKey) ? ['key'] : [];
    return attributesToMap(excludedAttributes, exclude: true);
  }

  Profile fromCacheFormat(Map<String, dynamic> fromCache) {
    Profile profile = new Profile();
    profile.risk = fromCache['risk'];
    profile.email = fromCache['email'];
    profile.username = fromCache['username'];
    return profile;
  }

  static bool isProfileList(dynamic field) {
    // TODO validate the attributes as well in the future
    return field is List<Profile>;
  }

  Map<String, dynamic> attributesToMap(List<String> attributeNames, {bool exclude=false}) {
    Map allFields = this.toMap();

    if (exclude) {
      for (String name in attributeNames) {
        allFields.remove(allFields[name]);
      } 
      return allFields;

    } else {
      Map<String, String> parsedFieldMap = new Map<String, String>();
      for (String name in attributeNames) {
        parsedFieldMap[name] = allFields[name];
      } 
      return parsedFieldMap;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> attributes = {
      'risk': this._risk,
      'email': this._email,
      'username': this._username,
    };

    return attributes;
  }

  double getRisk() => _risk;
  String getEmail() => _email;
  String getUsername() => _username;
  set risk(double risk) => this._risk = risk;
  set email(String email) => this._email = email;
  set username(String username) => this._username = username;
}
