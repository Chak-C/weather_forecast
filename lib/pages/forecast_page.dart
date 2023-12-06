import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:weather_forecast/api_fn.dart';
import 'package:weather_forecast/csv_processes.dart/csv_class.dart';
import 'package:weather_forecast/data_analysis/flutter_tflite_modelling.dart';
import 'package:intl/intl.dart';
import 'package:weather_forecast/main.dart';

class WeatherForecastPage extends StatefulWidget {
  const WeatherForecastPage({super.key});

  @override
  State<WeatherForecastPage> createState() => _WeatherForecastPageState();
}

class _WeatherForecastPageState extends State<WeatherForecastPage> {
  late Model2 model;

  late List<List<dynamic>> _sequence;

  //variables, to be changed by models
  double temperature = -999.0;
  double forecastTemperature = -999.0;
  late double rainfall;
  late double wind;
  late String weather;
  
  var _testingoutput = List.filled(1, 0).reshape([1,1]);


  String getDate() {
    DateTime now = DateTime.now();

    return DateFormat('MMMM d, y').format(now);
  }

  @override
  void initState() {
    model = Model2();
    startModel();

    super.initState();
  }
  
  Future<void> startModel() async {
    await pullSequences();

    dynamic temp = await model.loadAndPredict(0, _sequence, _testingoutput);

    setState(() {
      if (temp is double) {
        temp = temp/10;
        temperature = double.parse(temp.toStringAsFixed(1));
      } else {
        temperature = -100.0;
      }
    });
  }

  Future<void> pullSequences() async {
    final appState = context.read<AppState>();

    LoadedCSV data = await fetchWeatherData(appState.days[appState.daysSelected]-1, appState.cities[appState.citySelected], false);
    _sequence = [convertToDouble(data.getColumn(4,1))];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Weather Information
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today - ${getDate()}', // Date
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Temperature: $temperature°C'),
                        const Text('Wind: XX km/h'), // TODO windspeed
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    const Text('(?) Cloudy with occasional rain (?)'), // TODO Weather description
                    const SizedBox(height: 10.0),
                    Image.asset('assets/icons/rain.png', height: 50, width: 50), // Weather icon
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // Weather Charts or Plots (Placeholder)
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temperature Forecast', // Chart title
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // Placeholder for weather chart or graph (can use charts_flutter or other charting libraries)
                    Container(
                      height: 200.0,
                      color: Colors.grey[300],
                      // Add your chart here
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}