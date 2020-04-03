import 'dart:async';
import 'dart:math';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';


void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget random_code = Text('No qr code has been generated');
	String code_str = "";
	String scanned_code = "";

  @override
  initState() {
    super.initState();
		randomQr();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
            appBar: new AppBar(
              title: new Text('Barcode Scanner Testing'),
              backgroundColor: Colors.deepPurple,
            ),
            body: SafeArea(
							child: Center(
							  child: Column(
              children: <Widget>[
							  	Text('Scanned code: $scanned_code'),
                Container(
							  		child: RaisedButton(
							  			onPressed: scan,
							  			child: Text('Scan a code'),
							  			padding: EdgeInsets.all(8.0),
                	)),
							  	Container(
							  		child: RaisedButton(
							  			onPressed: randomQr,
							  			child: Text('Generate a brand new code')
							  		)
							  	),
							  	Text('Set code: $code_str'),
							  	this.random_code,
              ],
            ),
							))));
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.scanned_code = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.scanned_code = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.scanned_code = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.scanned_code =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.scanned_code = 'Unknown error: $e');
    }
  }

	void randomQr() {
		Random rand = new Random();

		setState(() {
			this.code_str = rand.nextInt(9999999).toString();
			this.random_code = new QrImage(
				data: this.code_str,
				version: QrVersions.auto,
				size: 200.0,
			);
		});
		print("Generated code ${this.code_str}");

	} 

}
