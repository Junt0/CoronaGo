import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/profile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/services/api_helper.dart';

import 'auth_user.dart';

class Interaction {
  String _uuid = "";
  List<Profile> _participants;
  DateTime _meetTime;
  DateTime _endTime;

  Interaction();

  Interaction.fromResponse(Map<String, dynamic> parsedJson) {
    _uuid = parsedJson['interaction_code'];
    _participants = this._loadParticipants(parsedJson['participants']);
    _meetTime = this._loadDateTime(parsedJson['meet_time']);
    _endTime = this._loadDateTime(parsedJson['end_time']);
  }

  static Future<Interaction> fromQrCode(AuthUser user, GlobalKey<ScaffoldState> scaffoldKey) async {
    InteractionEndpoints endpoint = new InteractionEndpoints(user);
    Interaction newInteraction = new Interaction();
    
    String uuid = await newInteraction.scanQr(scaffoldKey);
    if(newInteraction.isUUIDValid(uuid)) {
      newInteraction = await endpoint.join(uuid);
      if (newInteraction != null) {
        return newInteraction;
      }
      
      throw Exception('Failed to join interaction');
    } else {
      throw Exception('Scanner failed to function');
    }
  }

  String getUUID() => _uuid;
  List<Profile> getParticipants() => _participants;
  DateTime getMeetTime() => _meetTime;
  DateTime getEndTime() => _endTime;

  void setUUID(String uuid) {
    this._uuid = uuid;
  }

  // TODO test this
  bool isUUIDValid(String uuid) {
    final regExp = new RegExp(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$");
    return regExp.hasMatch(uuid);
  }

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

  Future<String> scanQr(GlobalKey<ScaffoldState> scaffoldKey) async {
    String message = "";
    bool error = true;
    String uuid = "";

    try {
      uuid = await BarcodeScanner.scan();
      print(uuid);
      error = false;
      message = "The code was scanned!";
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        message = 'The user did not grant the camera permission!';
      } else {
        message = 'Unknown error: $e';
      }
    } on FormatException {
      message = 'You pressed the back button before scanning anthing)';
    } catch (e) {
      message = 'Unknown error: $e';
    }


    print('returning');
    return uuid;
  }
}