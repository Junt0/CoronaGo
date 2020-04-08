part of screens;


class OverviewScreen extends StatefulWidget {
  static const String id = 'home';

  @override
  _OverviewScreen createState() => _OverviewScreen();
}


class _OverviewScreen extends State<OverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(child: Text("This is the overview screen"),)
    );
  }
}