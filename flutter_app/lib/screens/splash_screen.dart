part of screens;

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';

  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
       
    WidgetsBinding.instance
        .addPostFrameCallback((_) => this.attemptLogin());
  }

  void attemptLogin() async {
    Stopwatch dur = new Stopwatch()..start();

    AuthUser user = AuthUser.fromHive();
    APIAuth auth = new APIAuth(user);
    bool success = await auth.login();

    while (dur.elapsed.inSeconds < 2) {
       sleep(new Duration(milliseconds: 250));
    }

    if (success) {
      Navigator.pushReplacementNamed(context, OverviewScreen.id);
    } else {
      Navigator.pushReplacementNamed(context, AuthScreen.id);
    }

    
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Stack(
                  children: <Widget>[
                    // Stroked text as border.
                    Text(
                      'CG',
                      style: TextStyle(
                        fontSize: 200,
                        fontFamily: "Montserrat",
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 15
                          ..color = Color(0xFF4D3B67),
                      ),
                    ),
                    // Solid text as fill.
                    Text(
                      'CG',
                      style: TextStyle(
                        fontSize: 200,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w900,
                        color: Colors.white//Colors.white
                      ),
                    ),
                  ],
                ),
              ),
              SpinKitDoubleBounce(
                color: Theme.of(context).accentColor,
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
