part of screens;

class AuthScreen extends StatefulWidget {
  static const String id = 'app_auth';

  @override
  _AuthScreen createState() => _AuthScreen();
}

class _AuthScreen extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text("Signup"),
              onPressed: () => Navigator.popAndPushNamed(context, SignupScreen.id),
            ),
            RaisedButton(
              child: Text("Login"),
              onPressed: () => Navigator.popAndPushNamed(context, LoginScreen.id),
            ),
          ],
        ),
      ),
    );
  }
}
