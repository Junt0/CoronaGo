  import 'package:flutter/material.dart';

void showMessage(GlobalKey<ScaffoldState> scaffoldKey, String message, {Color color = Colors.red}) {
    print(message);
    scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        backgroundColor: color,
        content: new Text(message),
      ),
    );
  }
