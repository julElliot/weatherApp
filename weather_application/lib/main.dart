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
  var time;
  WeatherInfo(this.description, this.temp, this.time);
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

  List<WeatherInfo> weatherInfo = [];

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

    for (var number = 0;  number < 40; number++) {
      WeatherInfo info = WeatherInfo(result['list'][number]['weather'][0]['description'], result['list'][number]['main']['temp'], result['list'][number]['dt_txt']);
      weatherInfo.add(info);
    }
  }

  @override
  void initState () {
    super.initState();
    this.getWeather();
    this.getWeatherFor5Days();
  }


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
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Minsk', style: TextStyle(
                color: Colors.black
            )),
            backgroundColor: Colors.white,
          ),
          body:
          Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "Currently in Minsk",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    Text(
                        temp != null ? (temp - 273.15).round().toString() + "\u00B0" : "Loading",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 40.0,
                            fontWeight: FontWeight.w600
                        )
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                            currently != null ? currently.toString() : "Loading",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600
                            )
                        )
                    )
                  ],
                ),
              ),

              Expanded(
                  //color: Colors.white,

                  child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: ListView(
                          children: <Widget>[
                            ListTile(
                              leading: FaIcon(MdiIcons.temperatureCelsius),
                              title: Text("Temperature"),
                              trailing: Text(temp != null ? (temp - 273.15).round().toString() + "\u00B0" : "Loading"),
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
        body: ListView.builder(
          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 16.0, right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new ListTile(
                      leading: FaIcon(FontAwesomeIcons.wind),
                      title: Text(weatherInfo[index].time.toString().substring(11, 16),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Colors.black
                        ),
                      ),
                      subtitle: Text(weatherInfo[index].description,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal
                            //color: Colors.black
                        ),
                      ),
                      trailing: Text(
                          weatherInfo[index].temp != null ?
                          (weatherInfo[index].temp - 273.15).round().toString() + "\u00B0" :
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