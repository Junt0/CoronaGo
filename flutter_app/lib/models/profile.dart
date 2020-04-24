import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  double _risk;
  String _email = "";
  String _username;

  Profile.fromJson(Map<String, dynamic> parsedJson) {
    _risk = double.parse(parsedJson['risk']);
    _email = parsedJson['user']['email'];
    _username = parsedJson['user']['username'];
  }

  double getRisk() => _risk;
  String getEmail() => _email;
  String getUsername() => _username;

  @override
  List<Object> get props => [_risk, _email, _username];
}
