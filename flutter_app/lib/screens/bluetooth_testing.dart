part of screens;

class BluetoothTest extends StatefulWidget {
  static const String id = 'bluetooth_testing';

  @override
  _BluetoothTest createState() => _BluetoothTest();
}

class _BluetoothTest extends State<BluetoothTest> {
  @override
  Widget build(BuildContext context) {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Barcode Scanner Testing'),
          backgroundColor: Colors.deepPurple,
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text('Press here to scan'),
                onPressed: () async {
                  // flutterBlue.startScan(timeout: Duration(seconds: 4));

                  // //Listen to scan results
                  // var subscription = flutterBlue.scanResults.listen((scanResult) {
                  //     // do something with scan result
                  //     for (ScanResult scan in scanResult) {
                  //       BluetoothDevice device = scan.device;
                  //       //   type: ${device.id.toString()}
                  //       print('${device.name} found! rssi: ${scan.rssi}dBm');
                  //     }
                  // });

                  // // Stop scanning
                  // flutterBlue.stopScan();

                  for (BluetoothDevice device in await flutterBlue.connectedDevices) {
                    print('Connected device: ${device.name} ${device.id}');
                    List<BluetoothService> services = await device.discoverServices();
                    services.forEach((service) {
                      // do something with service
                      print(service.deviceId);
                    });
                  }


                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
