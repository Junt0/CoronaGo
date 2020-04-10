import 'package:flutter/widgets.dart';
import 'package:flutter_app/services/api_helper.dart';
import 'package:flutter_app/services/user_service.dart';
import 'package:http/http.dart' as http;

class Interaction {
  String uuid = "";
  List<Profile> participants;
  DateTime meetTime;
  DateTime endTime;

  Interaction(this.uuid);

  static Interaction fromResponse(http.Response response) {
    APIHelper api = new APIHelper();
    Map responseMap = api.responseToMap(response);

    Interaction interaction = new Interaction("");
    interaction._loadUUID(responseMap);
    interaction._loadParticipants(responseMap);
    interaction._loadTimes(responseMap);

  }

  void _loadTimes(Map responseMap) {
    String start = responseMap['meet_time'];
    String end = responseMap['end_time'];
  }

  DateTime parseDateTimeString(String timeString) {

  }


  void _loadParticipants(Map responseMap) {

  }

  void _loadUUID(Map responseMap) {

  }

  void endNow(){

  }

  Widget generateBarcode() {

  }
}