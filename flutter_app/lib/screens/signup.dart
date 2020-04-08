part of screens;

class SignupScreen extends StatefulWidget {
  static const String id = 'app_signup';

  @override
  _SignupScreen createState() => _SignupScreen();
}

// TODO pick a less confusing color scheme
class _SignupScreen extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  User user = new User();

  Future<void> _submitForm() async {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('The form is invalid! Please review and correct');
    } else {
      form.save();

      APIAuth api = new APIAuth(user);
      bool successful = await api.signup(user);

      if (successful) {
        this.showMessage('Signed up successfully!', color: Colors.green[400]);
        await Future.delayed(Duration(milliseconds: 1500));
        Navigator.popAndPushNamed(context, LoginScreen.id);
      } else {
        this.showMessage('An error has occured, please try again',
            color: Theme.of(context).accentColor);
      }
    }
  }

  void showMessage(String message, {Color color = Colors.red}) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        backgroundColor: color,
        content: new Text(message),
      ),
    );
  }

  String _validateEmail(String email) {
    final RegExp regex = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (regex.hasMatch(email)) {
      return null;
    } else {
      return "An invalid email was entered";
    }
  }

  String _validateUsername(String username) {
    if (username.isEmpty) return 'Empty';
    return null;
  }

  String _validatePassword(String password) {
    if (password.length < 5) return "Password must be longer than 5 characters";
    return null;
  }

  String _validateBothPasswords(String confirmPassword) {
    String pass1Valid = this._validatePassword(this._pass.text);

    if (this._pass.text.isEmpty) {
      return "Empty";
    }

    if (pass1Valid == null && this._pass.text == confirmPassword) {
      return null;
    } else {
      return "Passwords do not match";
    }
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
                  hintText: 'Enter a username',
                  labelText: 'Username',
                ),
              ),
              new TextFormField(
                validator: this._validateEmail,
                onSaved: (email) => user.setEmail(email),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  labelText: 'Email',
                ),
              ),
              new TextFormField(
                controller: this._pass,
                validator: this._validatePassword,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  labelText: 'Password',
                ),
              ),
              new TextFormField(
                onSaved: (confirmPass) => user.setPassword(confirmPass),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password again',
                  labelText: 'Confirm Password',
                ),
                controller: this._confirmPass,
                validator: this._validateBothPasswords,
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
