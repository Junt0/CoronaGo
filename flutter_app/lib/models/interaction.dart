import 'package:flutter_app/models/profile.dart';

class Interaction {
  String _uuid = "";
  List<Profile> _participants;
  DateTime _meetTime;
  DateTime _endTime;

  Interaction.fromResponse(Map<String, dynamic> parsedJson) {
    _uuid = parsedJson['unique_id'];
    _participants = this._loadParticipants(parsedJson['participants']);
    _meetTime = this._loadDateTime(parsedJson['meet_time']);
    _endTime = this._loadDateTime(parsedJson['end_time']);

  }

  String getUUID() => _uuid;
  List<Profile> getParticipants() => _participants;
  DateTime getMeetTime() => _meetTime;
  DateTime getEndTime() => _endTime;


  List<Profile> _loadParticipants(List<Map> particpants) {
    List<Profile> profiles = new List<Profile>();
    for (Map<String, dynamic> profileJson in particpants) {
      profiles.add(Profile.fromJson(profileJson));
    }
    return profiles;
  }

  DateTime _loadDateTime(dynamic datetime)  {
    if (datetime == null) {
      return null;
    } else {
      return DateTime.parse(datetime);
    }
  }
}