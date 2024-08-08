import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app2/additonal_info.dart';
import 'package:weather_app2/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    // Fetch current weather data from API
    // Replace "YOUR_API_KEY" with your actual API key
    try {
      const apiKey = 'cc155c19a745200de4969b05cf367f1f';
      const String city = 'London';
      const String url =
          'http://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey';

      final response = await http.get(Uri.parse(url));

      final weatherData = jsonDecode(response.body);
      if (weatherData['cod'] != '200') {
        throw Exception('Unexpected error ocurred');
      }
      return weatherData;
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh weather data here
              setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                  'Failed to load weather data: ${snapshot.error.toString()}'),
            );
          }

          final weatherData = snapshot.data!;
          final currentTemp = weatherData['list'][0]['main']['temp'];
          final currentSky = weatherData['list'][0]['weather'][0]['main'];
          final currentPressure = weatherData['list'][0]['main']['pressure'];
          final currentWind = weatherData['list'][0]['wind']['speed'];
          final currentHumidity = weatherData['list'][0]['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '${currentTemp.toStringAsFixed(2)} K', // in kelvin
                                // '${currentTemp - 273.15}°C', // Convert from Kelvin to Celsius if u want like this
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                '$currentSky',
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ), //fallbackHeight: 250, //this helps us to hold temporary height then it disappears if we have a chil

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                /*  SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [

                     for(int i = 1; i<=5; i++) //no need of parenthesis
                       HourlyForcastItem(
                        time: weatherData['list'][i]['dt'].toString(),
                        temperature: weatherData['list'][i]['main']['temp'].toString(),
                        icon: weatherData['list'][0]['weather'][0]['main'] == 'Clouds' || weatherData['list'][0]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny,
                      ),
                      
                    ],
                  ),
                ), */
                //the above commented code decrease the performance of our app because it loads all the widget at once when the
                //the i value increases it affect the prformance highly
                //so to solve this problem we need to use the following listview method, which will load leasly not all at once. this enhances the performance.
                //by default it takes the entire screen so we have to specify how much height or width it takes by wrappig it with sizedbox widget

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    //the index starts from 0
                    scrollDirection:
                        Axis.horizontal, //by default it scrolls vertically
                    itemCount: 10, // if we only want 5 widget now
                    itemBuilder: (context, index) {
                      final hourlyForecast = weatherData['list'][index + 1];
                      final hourlySky =
                          weatherData['list'][0]['weather'][0]['main'];
                          final time = DateTime.parse(hourlyForecast['dt_txt']);
                      return HourlyForcastItem(
                          time: DateFormat.j().format(time),
                          temperature: hourlyForecast['main']['temp'].toString(),
                          icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny);
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currentHumidity.toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      label: 'Wind speed',
                      value: currentWind.toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: currentPressure.toString(),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
