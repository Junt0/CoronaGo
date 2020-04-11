class Profile {
  double _risk;
  String _email = "";
  String _username;

  Profile.fromResponse(Map<String, dynamic> parsedJson) {
    _risk = double.parse(parsedJson['risk']);
    _email = parsedJson['user']['email'];
    _username = parsedJson['user']['username'];
  }

  double getRisk() => _risk;
  String getEmail() => _email;
  String getUsername() => _username;
}
