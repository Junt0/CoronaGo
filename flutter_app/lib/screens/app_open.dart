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
