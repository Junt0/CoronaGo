// import 'dart:async';
// import 'dart:math';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:barcode_scan/barcode_scan.dart';
// import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app/screens/screenslib.dart';
import 'package:flutter_app/services/api_helper.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

import 'models/auth_user.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('USER');
  String initial = await attemptLogin();
  runApp(new MyApp(initial));
}

Future<String> attemptLogin() async {
  AuthUser user = AuthUser.fromHive();
  APIAuth auth = new APIAuth(user);
  bool success = await auth.login();

  if (success) {
    return OverviewScreen.id;
  } else {
    return AuthScreen.id;
  }
}

class MyApp extends StatelessWidget {
  String initalRoute = "SplashScreen.id";
  MyApp(this.initalRoute);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return new MaterialApp(
        title: "CoronaGo",
        theme: new ThemeData(
          primaryColor: Color(0xff2E1E43),
          backgroundColor: Color(0xFF2D1D40),
          brightness: Brightness.dark,
          accentColor: Color(0xffFE4A49),
          fontFamily: 'Open Sans',
        ),
        initialRoute: this.initalRoute,
        routes: {
          SplashScreen.id: (context) => SplashScreen(),
          AuthScreen.id: (context) => AuthScreen(),
          HomeScreen.id: (context) => HomeScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          SignupScreen.id: (context) => SignupScreen(),
          OverviewScreen.id: (context) => OverviewScreen(),
        });
  }
}

// class _MyAppState extends State<MyApp> {
//   Widget randomCode = Text('No qr code has been generated');
// 	String codeStr = "";
// 	String scannedCode = "";

//   @override
//   initState() {
//     super.initState();
// 		randomQr();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//         home: new Scaffold(
//             appBar: new AppBar(
//               title: new Text('Barcode Scanner Testing'),
//               backgroundColor: Colors.deepPurple,
//             ),
//             body: SafeArea(
// 							child: Center(
// 							  child: Column(
//               children: <Widget>[
// 							  	Text('Scanned code: $scannedCode'),
//                 Container(
// 							  		child: RaisedButton(
// 							  			onPressed: scan,
// 							  			child: Text('Scan a code'),
// 							  			padding: EdgeInsets.all(8.0),
//                 	)),
// 							  	Container(
// 							  		child: RaisedButton(
// 							  			onPressed: randomQr,
// 							  			child: Text('Generate a brand new code')
// 							  		)
// 							  	),
// 							  	Text('Set code: $codeStr'),
// 							  	this.randomCode,
//               ],
//             ),
// 							))));
//   }

//   Future scan() async {
//     try {
//       String barcode = await BarcodeScanner.scan();
//       setState(() => this.scannedCode = barcode);
//     } on PlatformException catch (e) {
//       if (e.code == BarcodeScanner.CameraAccessDenied) {
//         setState(() {
//           this.scannedCode = 'The user did not grant the camera permission!';
//         });
//       } else {
//         setState(() => this.scannedCode = 'Unknown error: $e');
//       }
//     } on FormatException {
//       setState(() => this.scannedCode =
//           'null (User returned using the "back"-button before scanning anything. Result)');
//     } catch (e) {
//       setState(() => this.scannedCode = 'Unknown error: $e');
//     }
//   }

// 	void randomQr() {
// 		Random rand = new Random();

// 		setState(() {
// 			this.codeStr = rand.nextInt(9999999).toString();
// 			this.randomCode = new QrImage(
// 				data: this.codeStr,
// 				version: QrVersions.auto,
// 				size: 200.0,
// 			);
// 		});
// 		print("Generated code ${this.codeStr}");

// 	}

// }
