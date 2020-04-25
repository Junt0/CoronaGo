import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/profile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/services/api_helper.dart';
import 'package:flutter_app/services/caching.dart';

import 'auth_user.dart';

class Interaction extends CachedClass {
  String key;

  String _uuid = "";
  List<Profile> _participants;
  DateTime _meetTime;
  DateTime _endTime;

  DateTime lastUpdated;
  Map<String, Function> validators;

  Interaction(){
    this._loadValidators();
  }

  Map<String, dynamic> toCacheFormat({bool excludeKey = true}) {  
    List excludedAttributes = (excludeKey) ? ['key'] : [];
    return attributesToMap(excludedAttributes, exclude: true);
  }

  Interaction fromCacheFormat(Map<String, dynamic> fromCache) {
    this.uuid = fromCache['uuid'];
    this.key = _uuid;
    this.participants = this._loadParticipantsCache(fromCache['participants']);
    this.meetTime = this._loadDateTime(fromCache['meetTime']);
    this.endTime = this._loadDateTime(fromCache['endTime']);
    this.lastUpdated = this._loadDateTime(fromCache['lastUpdated']);

    return this;
  }

  void _loadValidators() {
    Map<String, Function> validators = {
      'uuid': CachedClass.isUUID,
      'participants': Profile.isProfileList,
    };
    this.validators = validators;
  }

  Interaction.fromResponse(Map<String, dynamic> parsedJson) {
    this._loadValidators();
    _uuid = parsedJson['interaction_code'];
    _participants = this._loadParticipantsJson(parsedJson['participants']);
    _meetTime = this._loadDateTime(parsedJson['meet_time']);
    _endTime = this._loadDateTime(parsedJson['end_time']);
    lastUpdated = this._loadDateTime(parsedJson['last_updated']);
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

  Map<String, dynamic> toMap() {
    Map<String, dynamic> attributes = {
      'uuid': this._uuid,
      'key': this.key,
      'lastUpdated': this.lastUpdated.toIso8601String(),
      'participants': this._participantsToMaps(),
      'meetTime': this._meetTime.toIso8601String(),
      'endTime': this._endTime.toIso8601String(),
    };

    return attributes;
  }

  List<Map<String, dynamic>> _participantsToMaps() {
    List<Map<String, dynamic>> participantMaps = [];
    for (Profile prof in this._participants) {
      participantMaps.add(prof.toMap());
    }
    return participantMaps;
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

  String getUUID() => _uuid;
  List<Profile> getParticipants() => _participants;
  DateTime getMeetTime() => _meetTime;
  DateTime getEndTime() => _endTime;
  set uuid(String uuid) => this._uuid = uuid;
  set participants(List<Profile> profiles) => this._participants = profiles;
  set meetTime(DateTime time) => this._meetTime = time;
  set endTime(DateTime time) => this._endTime = time;

  void setUUID(String uuid) {
    this._uuid = uuid;
  }

  // TODO test this
  bool isUUIDValid(String uuid) {
    final regExp = new RegExp(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$");
    return regExp.hasMatch(uuid);
  }

  List<Profile> _loadParticipantsJson(List<Map> particpants) {
    List<Profile> profiles = new List<Profile>();
    for (Map<String, dynamic> profileJson in particpants) {
      profiles.add(Profile.fromJson(profileJson));
    }
    return profiles;
  }

  List<Profile> _loadParticipantsCache(List<Map> particpants) {
    List<Profile> profiles = new List<Profile>();
    for (Map<String, dynamic> profile in particpants) {
      profiles.add(new Profile()..fromCacheFormat(profile));
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