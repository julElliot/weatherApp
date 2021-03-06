import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_share/flutter_share.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// Class description for the next 5 days every 3 hours.
class WeatherInfo {
  var description;
  var temp;
  var time;
  var icon;
  WeatherInfo(this.description, this.temp, this.time, this.icon);
}

/// Column contains icon and its description.
Column _buildButtonColumn(Color color, IconData icon, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: color),
      Container(
        margin: const EdgeInsets.only(top: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      ),
    ],
  );
}

class _HomeScreenState extends State<HomeScreen> {

  var temp;
  var description;
  var currently;
  var humidity;
  var windSpeed;
  var pressure;
  var windDirection;
  var _curIndex = 0;
  var addresses;
  var first;
  var name;
  var suitableIcon = MdiIcons.weatherSunny;
  bool isInternetConnected = false;
  List<WeatherInfo> weatherInfo = [];

  /// Check internet connection.
  _checkInternetConnectivity() async{
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      isInternetConnected = false;
    }
    else isInternetConnected = true;
  }

  /// Function to share weather as text.
  Future<void> share() async {
    String sharedText;
    if ((temp != null) && (description != null) && (name != null)) {
      sharedText = 'In $name today: ' + (temp - 273.15).round().toString() + '\u00B0C and $description';
    }
    else sharedText = 'no information';
    await FlutterShare.share(
        title: 'Shared weather',
        text: sharedText,
        linkUrl: '',
        chooserTitle: 'Title');
  }

  /// Function to define current geo position.
  Position _currentPosition;
  _getCurrentLocation() {
    final Geolocator geolocation = Geolocator()..forceAndroidLocationManager;
    geolocation
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  /// Getting information for today from API.
  Future getWeather () async {
    _getCurrentLocation();
    http.Response response = await http.get("http://api.openweathermap.org/data/2.5/weather?lat=53&lon=28&appid=4f8c59216c41ae9c18d1af6ddc81a0c6");
    var result = jsonDecode(response.body);
    setState(() {
      this.name = result['name'];
      this.temp = result['main']['temp'];
      this.description = result['weather'][0]['description'];
      this.currently = result['weather'][0]['main'];
      this.humidity = result['main']['humidity'];
      this.pressure = result['main']['pressure'];
      this.windSpeed = result['wind']['speed'];
      this.windDirection = result['wind']['deg'];
    });
    setWindDirection();
  }

  /// Getting information for the next 5 days from API.
  Future getWeatherFor5Days () async {
    http.Response response = await http.get("http://api.openweathermap.org/data/2.5/forecast?lat=53&lon=28&appid=4f8c59216c41ae9c18d1af6ddc81a0c6");
    var result = jsonDecode(response.body);

    for (var number = 0;  number < 40; number++) {
      WeatherInfo info = WeatherInfo(result['list'][number]['weather'][0]['description'],
          result['list'][number]['main']['temp'], result['list'][number]['dt_txt'], MdiIcons.weatherSunny);
      weatherInfo.add(info);
    }
  }

  /// Define wind direction according to the degree.
  void setWindDirection(){
    if ((windDirection <= 10) || (windDirection >= 350)) {windDirection = 'N';}
    else if ((windDirection > 10) && (windDirection < 80)) {windDirection = 'NE';}
    else if ((windDirection >= 80) && (windDirection <= 100)) {windDirection = 'E';}
    else if ((windDirection > 100) && (windDirection < 170)) {windDirection = 'SE';}
    else if ((windDirection >= 170) && (windDirection <= 190)) {windDirection = 'S';}
    else if ((windDirection > 190) && (windDirection < 260)) {windDirection = 'SW';}
    else if ((windDirection >= 260) && (windDirection <= 280)) {windDirection = 'W';}
    else if ((windDirection > 280) && (windDirection < 350)) {windDirection = 'NW';}
  }

  /// Define suitable icon according to the description.
  _setSuitableIcon(){
    if ((description == 'overcast clouds') || (description == 'broken clouds') || (description == 'scattered clouds')){
      suitableIcon = MdiIcons.weatherCloudy;
    }
    else if (description == 'few clouds'){
      suitableIcon = MdiIcons.weatherPartlyCloudy;
    }
    else if (description == 'clear sky'){
      suitableIcon = MdiIcons.weatherSunny;
    }
    else if (description == 'light rain'){
      suitableIcon = MdiIcons.weatherPartlyRainy;
    }
  }

  /// Define suitable icon according to the description.
  ///
  /// Previous function cen be united with this one! I know
  _setSuitableIconFor5Days(){
    for (var number = 0;  number < 40; number++){
      if ((weatherInfo[number].description == 'overcast clouds') || (weatherInfo[number].description == 'broken clouds') || (weatherInfo[number].description == 'scattered clouds')){
        weatherInfo[number].icon = MdiIcons.weatherCloudy;
      }
      else if (weatherInfo[number].description == 'few clouds'){
        weatherInfo[number].icon = MdiIcons.weatherPartlyCloudy;
      }
      else if (weatherInfo[number].description == 'clear sky'){
        weatherInfo[number].icon = MdiIcons.weatherSunny;
      }
      else if (weatherInfo[number].description == 'light rain'){
        weatherInfo[number].icon = MdiIcons.weatherPartlyRainy;
      }
    }
  }

  @override
  void initState () {
    super.initState();
    this.getWeather();
    this.getWeatherFor5Days();
  }

  /// Rendering bottom navigation bar.
  Widget _bottomNormal()=> BottomNavigationBar(
      backgroundColor: Colors.white,
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
            MdiIcons.weatherPartlyRainy,
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
        });
      });

  @override
  Widget build (BuildContext context) {
    _checkInternetConnectivity();
    if (!isInternetConnected) {
      //_getCurrentLocation();
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('No internet connection', style: TextStyle(
              color: Colors.black
          )),
          backgroundColor: Colors.white,
        ),
      );
    }
    else {
      if (_curIndex == 0) {
        _setSuitableIcon();
        return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Today",
                  style: TextStyle(
                      color: Colors.black
                  )),
              backgroundColor: Colors.white,
            ),
            body:
            Column(
              children: <Widget>[
                Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height / 3,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  color: Colors.white,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Icon(suitableIcon, size: 80.0,
                                color: Colors.orangeAccent)
                        ),
                        Text(
                            name != null ? name.toString() : 'Loading',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w300
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                                ((currently != null) && (temp != null))
                                    ? (temp - 273.15).round().toString() +
                                    "\u00B0C" + ' | ' + currently.toString()
                                    : "Loading",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w300
                                )
                            )
                        )
                      ]
                  ),
                ),

                Expanded(
                    child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
                        child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,

                                children: [
                                  _buildButtonColumn(Colors.orangeAccent,
                                      MdiIcons.weatherRainy,
                                      humidity != null ? humidity.toString() +
                                          '%' : "Loading"),
                                  _buildButtonColumn(
                                      Colors.orangeAccent, MdiIcons.water, '?'),
                                  _buildButtonColumn(Colors.orangeAccent,
                                      MdiIcons.temperatureCelsius,
                                      pressure != null ? pressure.toString() +
                                          ' hPh' : "Loading"),
                                ],
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                children: [
                                  _buildButtonColumn(Colors.orangeAccent,
                                      MdiIcons.weatherWindy,
                                      windSpeed != null ? (windSpeed * 3.6)
                                          .toStringAsFixed(2) + ' km/h' : "Loading"),
                                  _buildButtonColumn(
                                      Colors.orangeAccent, MdiIcons.compass,
                                      windDirection != null ? windDirection
                                          .toString() : "Loading"),
                                ],
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FlatButton(
                                      onPressed: () {
                                        share();
                                      },
                                      child: Text('Share',
                                          style: TextStyle(
                                              color: Colors.deepOrangeAccent,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w300))
                                  )
                                ],
                              )
                            ]
                        )
                    )
                ),
              ],
            ),
            bottomNavigationBar: _bottomNormal()
        );
      }
      else
        _setSuitableIconFor5Days();
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(name != null ? name : "loading",
                style: TextStyle(
                    color: Colors.black
                )),
            backgroundColor: Colors.white,
          ),
          body: ListView.builder(
            itemBuilder: (context, index) {
              return Card(
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new ListTile(
                            leading: Icon(weatherInfo[index].icon, size: 50.0, color: Colors.orangeAccent),
                            title: Text(
                              weatherInfo != null ? weatherInfo[index].time
                                  .toString().substring(11, 16) : "Loading",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black
                              ),
                            ),
                            subtitle: Text(
                              weatherInfo != null ? weatherInfo[index]
                                  .description : "Loading",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal
                                //color: Colors.black
                              ),
                            ),
                            trailing: Text(
                              weatherInfo[index].temp != null ?
                              (weatherInfo[index].temp - 273.15)
                                  .round()
                                  .toString() + "\u00B0" :
                              "Loading",
                              style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.blue
                              ),
                            ),
                          )
                        ],
                      )
                  )
              );
            },
            itemCount: weatherInfo.length,
          ),
          bottomNavigationBar: _bottomNormal()
      );
    }
  }
}