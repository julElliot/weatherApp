import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:weatherapplication/home_screen.dart';
import 'package:weatherapplication/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  final routes = <String, WidgetBuilder>{
    '/Home': (BuildContext context) => HomeScreen()
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(nextRoute: '/Home'),
      routes: routes,
    );
  }
}
