part of screens;


class LoginScreen extends StatefulWidget {
  static const String id = 'app_login';

  @override
  _LoginScreen createState() => _LoginScreen();
}

// TODO pick a less confusing color scheme
class _LoginScreen extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AuthUser user = new AuthUser();

  Future<void> _submitForm() async {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('The form is invalid! Please review and correct');
    } else {
      form.save();
      APIAuth auth = new APIAuth(user);
      bool successful = await auth.login(user);

      if (successful) {
        this.showMessage('Logged in successfully!', color: Colors.green[400]);
        await Future.delayed(Duration(milliseconds: 1500));
        // Removes all previous routes and adds new route to prevent going back to the original auth screen
        Navigator.of(context).pushNamedAndRemoveUntil(OverviewScreen.id, (Route<dynamic> route) => false);
      } else {
        this.showMessage('An error has occured, please try again',
            color: Theme.of(context).accentColor);
      }

    }
  }

  void showMessage(String message, {Color color = Colors.red}) {
    print(message);
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        backgroundColor: color,
        content: new Text(message),
      ),
    );
  }

  String _validateUsername(String username) {
    if (username.isEmpty) return 'Empty';
    return null;
  }

  String _validatePassword(String password) {
    if (password.length < 5) return "Password must be longer than 5 characters";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: this._scaffoldKey,
      body: SafeArea(
        child: new Form(
          key: _formKey,
          autovalidate: true,
          child: new ListView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: <Widget>[
              new TextFormField(
                validator: this._validateUsername,
                onSaved: (username) => user.setUsername(username),
                decoration: InputDecoration(
                  hintText: 'Enter your username',
                  labelText: 'Username',
                ),
              ),
              new TextFormField(
                controller: this._pass,
                onSaved: (password) => user.setPassword(password),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  labelText: 'Password',
                ),
              ),
              new Container(
                padding: EdgeInsets.only(top: 20),
                child: new RaisedButton(
                  child: Text("Submit"),
                  onPressed: this._submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
