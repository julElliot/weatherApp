import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


void main() {
  runApp(
      new MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Weather Application",
          home: Home(),
          )
  );
}

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class WeatherInfo {
  var description;
  var temp;
  WeatherInfo(this.description, this.temp);
}

class HomeState extends State<Home> {

  var temp;
  var description;
  var currently;
  var humidity;
  var windSpeed;
  var _curIndex = 0;
  var contents = "Home";
  var result2;
  //var result;

  List<WeatherInfo> weatherInfo = [];

  /*var time;
  var description_for_every_3hours;
  var temp_for_every_3hours;*/

  // getting information for today from API
  Future getWeather () async {
    http.Response response = await http.get("http://api.openweathermap.org/data/2.5/weather?q=Minsk&appid=4f8c59216c41ae9c18d1af6ddc81a0c6");
    var result = jsonDecode(response.body);
    setState(() {
      this.temp = result['main']['temp'];
      this.description = result['weather'][0]['description'];
      this.currently = result['weather'][0]['main'];
      this.humidity = result['main']['humidity'];
      this.windSpeed = result['wind']['speed'];
    });
  }

  // getting information for the next 5 days from API
  Future getWeatherFor5Days () async {
    http.Response response = await http.get("http://api.openweathermap.org/data/2.5/forecast?q=Minsk&appid=4f8c59216c41ae9c18d1af6ddc81a0c6");
    var result = jsonDecode(response.body);
    //result2 = result['list'][5]['weather'][0]['description'];

    for (var number = 0;  number < 40; number++) {
      WeatherInfo info = WeatherInfo(result['list'][number]['weather'][0]['description'], result['list'][number]['main']['temp']);
      weatherInfo.add(info);
    }
    //print(weatherInfo.length);
    /*setState(() {
      this.time = result['main']['temp'];
      this.description_for_every_3hours = result['weather'][0]['description'];
      this.temp_for_every_3hours['weather'][0]['main'];
    });*/
  }

  @override
  void initState () {
    super.initState();
    this.getWeather();
    this.getWeatherFor5Days();
    //print(result2.toString());
    //debugPrint(result2);
  }



  Widget _bottomNormal()=> BottomNavigationBar(
    items: [
      BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(
          MdiIcons.weatherSunny,
          size: 15,
        ),
        title: Text(
          "Today",
          style: TextStyle(fontSize: 15),
        ),
      ),
      BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(
          MdiIcons.weatherFog,
          size: 15,
        ),
        title: Text(
          "Forecast",
          style: TextStyle(fontSize: 15),
        ),
      )
    ],
    type: BottomNavigationBarType.fixed,
    currentIndex: _curIndex,
    onTap: (index) {
      setState(() {
        _curIndex = index;
        switch (_curIndex) {
          case 0:
            contents = "Today";
            break;
          case 1:
            contents = "Forecast";
            break;
        }
      });
    });

  @override
  Widget build (BuildContext context) {
    if (_curIndex == 0 ) {
      return Scaffold(
          body:
          Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width,
                color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "Currently in Minsk",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    Text(
                        temp != null ? temp.toString() + "\u00B0" : "Loading",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.0,
                            fontWeight: FontWeight.w600
                        )
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                            currently != null ? currently.toString() : "Loading",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600
                            )
                        )
                    )
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: ListView(
                          children: <Widget>[
                            ListTile(
                              leading: FaIcon(MdiIcons.temperatureCelsius),
                              title: Text("Temperature"),
                              trailing: Text(temp != null ? temp.toString() + "\u00B0" : "Loading"),
                            ),
                            ListTile(
                              leading: FaIcon(FontAwesomeIcons.cloud),
                              title: Text("Weather"),
                              trailing: Text(description != null ? description.toString() : "Loading"),
                            ),
                            ListTile(
                              leading: FaIcon(FontAwesomeIcons.sun),
                              title: Text("Humidity"),
                              trailing: Text(humidity != null ? humidity.toString() : "Loading"),
                            ),
                            ListTile(
                              leading: FaIcon(FontAwesomeIcons.wind),
                              title: Text("Wind Speed"),
                              trailing: Text(windSpeed != null ? windSpeed.toString() : "Loading"),
                            )
                          ]
                      )
                  )
              )
            ],
          ),
          bottomNavigationBar: _bottomNormal()
      );
    }
    else return Scaffold(
        body:
        Text(
            "loading",
            style: TextStyle(
                color: Colors.purple,
                fontSize: 40.0,
                fontWeight: FontWeight.w600
            )
        ),
        bottomNavigationBar: _bottomNormal()
    );

  }
}