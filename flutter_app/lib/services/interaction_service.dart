import 'package:flutter/widgets.dart';
import 'package:flutter_app/services/user_service.dart';

class Interaction {
  String uuid = "";
  List<Profile> participants;
  DateTime meetTime;
  DateTime endTime;

  Interaction(this.uuid);

  static Interaction fromResponse() {

  }

  void endNow(){

  }

  Widget generateBarcode() {

  }
}