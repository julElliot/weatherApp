import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {

  final String nextRoute;
  SplashScreen({this.nextRoute});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
            () { Navigator.of(context).pushReplacementNamed(widget.nextRoute); }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigoAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Weather Forecast',
                style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 35.0,
                    fontWeight: FontWeight.w500
                ))
          ],
        ),
      ),
    );
  }
}