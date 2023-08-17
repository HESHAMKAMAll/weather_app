import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/widgets/additional_info_item.dart';
import 'package:weather_app/widgets/weather_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String cityName = "fayyum";

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final response = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey"));
      final data = jsonDecode(response.body);
      if (data["cod"] != "200") {
        Future.delayed(
          const Duration(seconds: 2),
          () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const WeatherScreen(),
              )),
        );
        throw '''
                   An unexpected error occurred.
        Make sure the city name is entered correctly😞.
         ''';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh)),
        ],
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: getCurrentWeather(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              final data = snapshot.data;

              final currentWeatherData = data!["list"][0];

              final currentTemp = currentWeatherData["main"]["temp"];
              final currentSky = currentWeatherData["weather"][0]["main"];
              final currentPressure = currentWeatherData["main"]["pressure"];
              final currentHumidity = currentWeatherData["main"]["humidity"];
              final currentWindSpeed = currentWeatherData["wind"]["speed"];

              fun() {
                var ne = currentTemp - 273.15;
                return ne;
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 8,
                        shadowColor: currentTemp >= 30 + 273.15
                            ? Colors.pink
                            : Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 10,
                            ),
                            // blendMode: BlendMode.clear,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text("${fun().toStringAsFixed(0)} °C",
                                      style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  currentSky == "Clear"
                                      ? const Icon(
                                          Icons.sunny,
                                          size: 64,
                                          color: Colors.yellow,
                                        )
                                      : const Icon(Icons.cloud, size: 64),
                                  const SizedBox(height: 10),
                                  Text(currentSky,
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Center(
                            child: Text(
                          "${data["city"]["name"]}",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: currentTemp > 29 + 273.15
                                  ? Colors.pink
                                  : Colors.blue),
                        )),
                        const Text(" Hourly Forecast",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: data["cnt"] - 1,
                        itemBuilder: (context, i) {
                          final hourlyForecast = data["list"][i + 1];
                          final time = DateTime.parse(hourlyForecast["dt_txt"]);
                          final tems = hourlyForecast["main"]["temp"];
                          fun() {
                            var ne = tems - 273.15;
                            return ne;
                          }

                          return HourlyForecastItem(
                            shadowColor:
                                tems > 29 + 273.15 ? Colors.pink : Colors.blue,
                            icon:
                                data["list"][i]["weather"][0]["main"] == "Clear"
                                    ? Icons.sunny
                                    : Icons.cloud,
                            time: DateFormat("j").format(time),
                            temperature: "${fun().toStringAsFixed(0)} °C",
                            iconColor:
                                data["list"][i]["weather"][0]["main"] == "Clear"
                                    ? Colors.yellow
                                    : Colors.white,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Additional Information",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoItem(
                          icon: Icons.water_drop,
                          label: "Humidity",
                          value: "$currentHumidity g.m-3",
                        ),
                        AdditionalInfoItem(
                          icon: Icons.air,
                          label: "Wind Speed",
                          value: "$currentWindSpeed m/s",
                        ),
                        AdditionalInfoItem(
                          icon: Icons.scale_sharp,
                          label: "Pressure",
                          value: "$currentPressure Pa",
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Card(
                      child: TextField(
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            cityName = value;
                            setState(() {});
                          } else {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WeatherScreen(),
                                ));
                          }
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_city_outlined),
                          hintText: "Enter Your City",
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
