part of screens;

class CodeScreen extends StatefulWidget {
  static const String id = 'code_screen';

  @override
  _CodeScreen createState() => _CodeScreen();
}

class _CodeScreen extends State<CodeScreen> {
  @override
  Widget build(BuildContext context) {
    final Interaction interaction = ModalRoute.of(context).settings.arguments;

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Barcode Scanner Testing'),
          backgroundColor: Colors.deepPurple,
        ),
        body: SafeArea(
          child: Center(
            child: new QrImage(
              data: interaction.getUUID(),
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
        ),
      ),
    );
  }
}
