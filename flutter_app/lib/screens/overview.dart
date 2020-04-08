part of screens;

class OverviewScreen extends StatefulWidget {
  static const String id = 'home';

  @override
  _OverviewScreen createState() => _OverviewScreen();
}

class _OverviewScreen extends State<OverviewScreen> {

  void logoutUser() {
    AuthUser user = AuthUser.loadFromHive();
    APIAuth auth = new APIAuth(user);
    auth.logout();
    Navigator.pushReplacementNamed(context, AuthScreen.id);
  }
  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      child: Column(
        children: <Widget>[
          Text("This is the overview screen"),
          RaisedButton(
            onPressed: () => this.logoutUser(),
            child: Text("Logout")
          ),
        ],
      ),
    ));
  }
}
