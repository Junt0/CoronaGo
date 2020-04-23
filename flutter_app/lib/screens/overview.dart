part of screens;

class OverviewScreen extends StatefulWidget {
  static const String id = 'home';

  @override
  _OverviewScreen createState() => _OverviewScreen();
}

class _OverviewScreen extends State<OverviewScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void logoutUser() {
    AuthUser user = AuthUser.fromHive();
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
              onPressed: () => this.logoutUser(), child: Text("Logout")),
          RaisedButton(
            onPressed: () async {
              try {
                Interaction interaction = await Interaction.fromQrCode(AuthUser.fromHive(), scaffoldKey);
                //Navigator.of(context).pushNamed(CodeScreen.id, arguments: interaction);
              } catch (e) {}
            },
            child: Text("Join an interaction"),
            padding: EdgeInsets.all(8.0),
          ),
          RaisedButton(
            //onPressed: Navigator.of(context).pushNamed(routeName),
            child: Text('Start an interaction'),
          ),
        ],
      ),
    ));
  }
}
