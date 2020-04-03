part of screens;

class AppLoading extends StatefulWidget {
  static const String id = 'app_loading';

  @override
  _AppOpen createState() => _AppOpen();
}

class _AppOpen extends State<AppLoading> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: SafeArea(
          child: Text("Test initial route"),
        ),
      ),
    );
  }
}
