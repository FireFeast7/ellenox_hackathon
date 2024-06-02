import 'dart:convert';

import 'package:ellenox_hackathon/models/button_row_model.dart';
import 'package:ellenox_hackathon/views/currentLocation.dart';
import 'package:ellenox_hackathon/models/message_container_model.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool showButtons = false;
  List<double> coordinates = [];
  String cityName = '';
  String cityInfo = '';

  @override
  void initState() {
    resetContext();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeValue = MediaQuery.of(context).platformBrightness;

    return Scaffold(
      backgroundColor: HexColor('#FEF9F4'),
      appBar: AppBar(
        backgroundColor: HexColor('#FEF9F4'),
        centerTitle: true,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
            child: Text(
              'Travel Buddy',
              style: TextStyle(color: HexColor('#343434')),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Body(
                messages: messages,
                showButtons: showButtons,
                coordinates: coordinates,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style:
                          TextStyle(color: Colors.black, fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(15)),
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                        labelStyle: TextStyle(color: Colors.black),
                        hintText: 'Send a message',
                      ),
                    ),
                  ),
                  IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage(messageController.text);
                      messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      addMessage({
        'text': text,
        'isUserMessage': true,
      });
      showButtons = false;
    });

    Map<String, dynamic> coord = await getCurrentLocation();
    var lat = coord['lat'];
    var long = coord['lon'];
    var response = await http.post(
      Uri.parse('https://travelbot-a2mf.onrender.com/process_prompt/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': text, 'lat': lat, 'lon': long}),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      var resultCode = responseBody['result'][0];
      if (resultCode == 1) {
        var resultString = responseBody['result'][1];
        var cityMatches =
            RegExp(r'\"null\", \"(.*?)\"').allMatches(resultString);
        if (cityMatches.isNotEmpty) {
          cityName = cityMatches.first.group(1)!;
          coordinates = responseBody['result'][2].cast<double>();

          setState(() {
            addMessage({
              'text':
                  'These are the results that I found for your query to travel to $cityName ',
              'isUserMessage': false,
            });
            showButtons = true;
          });
        }
      } else if (resultCode == 2) {
        var weatherData = WeatherData.fromJson(responseBody['result'][2]);
        setState(() {
          addMessage({
            'text': formatWeatherData(weatherData),
            'isUserMessage': false,
            'isWeatherMessage': true,
          });
        });

        var jsonString = formatWeatherDataAsJsonString(weatherData);
        var summarizeResponse = await http.post(
          Uri.parse('https://travelbot-summarizer.onrender.com/weather'),
          headers: {'Content-Type': 'application/json'},
          body: jsonString,
        );

        if (summarizeResponse.statusCode == 200) {
          var summarizeResponseBody = jsonDecode(summarizeResponse.body);
          setState(() {
            addMessage({
              'text': summarizeResponseBody['summary'],
              'isUserMessage': false,
            });
          });
        } else {
          print(
              'Failed to summarize weather data: ${summarizeResponse.statusCode}');
        }
      } else {
        print(response.body);

        var resultString = responseBody['result'][1];
        var cityInfoMatches =
            RegExp(r'\"Type_3\", \"(.*?)\"').allMatches(resultString);
        if (cityInfoMatches.isNotEmpty) {
          cityInfo = cityInfoMatches.first.group(1)!;
          cityInfo = cityInfo.replaceAll(r'\n', '\n');
        }
        setState(() {
          addMessage({
            'text': cityInfo.isNotEmpty ? cityInfo : 'No information available',
            'isUserMessage': false,
          });
        });
      }
    } else {
      print('Failed to fetch weather data: ${response.statusCode}');
    }
  }

  String formatWeatherData(WeatherData weatherData) {
    final Map<String, dynamic> formattedData = {
      'City': weatherData.cityName,
      'Temperature': '${formatTemperature(weatherData.temp)} °C',
      'Feels Like': '${formatTemperature(weatherData.feelsLike)} °C',
      'Min Temperature': '${formatTemperature(weatherData.tempMin)} °C',
      'Max Temperature': '${formatTemperature(weatherData.tempMax)} °C',
      'Weather':
          '${weatherData.weatherMain} (${weatherData.weatherDescription})',
      'Pressure': '${weatherData.pressure} hPa',
      'Humidity': '${weatherData.humidity}%',
      'Visibility': '${weatherData.visibility} m',
      'Wind Speed': '${weatherData.windSpeed} m/s',
      'Wind Degree': '${weatherData.windDeg}°',
      'Wind Gust': '${weatherData.windGust} m/s',
      'Cloudiness': '${weatherData.cloudiness}%',
      'Sunrise': formatTime(weatherData.sunrise),
      'Sunset': formatTime(weatherData.sunset),
    };

    final jsonString = jsonEncode(formattedData);

    print(jsonString);

    return '''
    City: ${weatherData.cityName},
    Temperature: ${formatTemperature(weatherData.temp)} °C,
    Feels Like: ${formatTemperature(weatherData.feelsLike)} °C,
    Min Temperature: ${formatTemperature(weatherData.tempMin)} °C,
    Max Temperature: ${formatTemperature(weatherData.tempMax)} °C,
    Weather: ${weatherData.weatherMain} (${weatherData.weatherDescription}),
    Pressure: ${weatherData.pressure} hPa,
    Humidity: ${weatherData.humidity}%, 
    Visibility: ${weatherData.visibility} m,
    Wind Speed: ${weatherData.windSpeed} m/s,
    Wind Degree: ${weatherData.windDeg}°,
    Wind Gust: ${weatherData.windGust} m/s,
    Cloudiness: ${weatherData.cloudiness}%, 
    Sunrise: ${formatTime(weatherData.sunrise)},
    Sunset: ${formatTime(weatherData.sunset)},
    ''';
  }

  String formatTemperature(double value) {
    return (value - 273.15).toStringAsFixed(2);
  }

  String formatTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        .toLocal()
        .toIso8601String()
        .split('T')[1]
        .substring(0, 5);
  }

  String formatWeatherDataAsJsonString(WeatherData weatherData) {
    final Map<String, dynamic> formattedData = {
      'City': weatherData.cityName,
      'Temperature': formatTemperature(weatherData.temp),
      'Feels Like': formatTemperature(weatherData.feelsLike),
      'Min Temperature': formatTemperature(weatherData.tempMin),
      'Max Temperature': formatTemperature(weatherData.tempMax),
      'Weather': weatherData.weatherMain,
      'Pressure': weatherData.pressure,
      'Humidity': weatherData.humidity,
      'Visibility': weatherData.visibility,
      'Wind Speed': weatherData.windSpeed,
      'Wind Degree': weatherData.windDeg,
      'Wind Gust': weatherData.windGust,
      'Cloudiness': weatherData.cloudiness,
      'Sunrise': formatTime(weatherData.sunrise),
      'Sunset': formatTime(weatherData.sunset),
    };

    return jsonEncode(formattedData);
  }

  void addMessage(Map<String, dynamic> message) {
    messages.add(message);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}

class Body extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final bool showButtons;
  final List<double> coordinates;

  const Body({
    Key? key,
    this.messages = const [],
    required this.showButtons,
    required this.coordinates,
  }) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, i) {
              var obj = widget.messages[widget.messages.length - 1 - i];
              bool isUserMessage = obj['isUserMessage'] ?? false;
              bool isWeatherMessage = obj['isWeatherMessage'] ?? false;
              return Row(
                mainAxisAlignment: isUserMessage
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MessageContainer(
                    text: obj['text'],
                    isUserMessage: isUserMessage,
                    isWeatherMessage: isWeatherMessage,
                  ),
                ],
              );
            },
            separatorBuilder: (_, i) => Container(height: 10),
            itemCount: widget.messages.length,
            reverse: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
          ),
        ),
        if (widget.showButtons)
          ButtonRow(
            coordinates: widget.coordinates,
          ),
      ],
    );
  }
}
