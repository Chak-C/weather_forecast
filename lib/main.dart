import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_forecast/api_fn.dart';
import 'package:weather_forecast/csv_processes.dart/csv_class.dart';
import 'package:weather_forecast/data_analysis/tf_modelling.dart';
import 'package:weather_forecast/pages/first_page.dart';
import 'package:weather_forecast/pages/forecast_page.dart';
import 'package:weather_forecast/support_widgets/dropdown_menu.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Weather Forecast',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
          useMaterial3: true,
        ),
        home: const HomePage(title: 'Weather Forecast'),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  //Global variables

  //datasets pulled
  late LoadedCSV dataMonthly; // season: ~3-6 weeks
  late LoadedCSV dataYearly; //  season: ???
  late LoadedCSV dataDecade; //  season: seasons (sum,aut,spr,win)

  //api data pull selection
  List<String> cities = ['Sydney']; //cities available
  List<int> days = [10,30,60]; //number of days we look back
  List<int> years = [5,7,10]; //number of years of data to pull (model development purposes)

  //dataset selections (duration, position of data, prediction wanted, effects included)
  int citySelected = -1;
  int daysSelected = -1;
  late int yearsSelected;

  //error handling
  bool selectionError = false;

  bool checkForecastSelectionsValid() {
    return (citySelected != -1 && daysSelected != -1);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void navigateToGraph(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoadPage()),
      );
    } catch (e) {
      // Handle and log any errors
    }
  }

  void onPredictPressed() {
    final appState = context.read<AppState>();
    print(appState.days[appState.daysSelected]);
    final valid = appState.checkForecastSelectionsValid();
    appState.selectionError = valid ? false : true;
    Future.delayed(const Duration(milliseconds: 100));

    if (valid) {
      navigateToForecast(context); //use push so can go back
    } else {
      navigateToPage(context, const HomePage(title: 'Please select valid options',));
    }
  }

  void navigateToPage(BuildContext context, Widget page) {
    try {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      // Handle and log any errors
    }
  }
  
  void navigateToForecast(BuildContext context) {
    try {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => const WeatherForecastPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      // Handle and log any errors
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const DropRow(prefix: 'City', dropdownNumber: 0),
            const SizedBox(height: 20),
            const DropRow(prefix: 'Days', dropdownNumber: 1),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onPredictPressed();
              },
              child: const Text('Predict'), // Replace 'Button Text' with your desired label
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              // Grab data and save into appState
              appState.dataMonthly = await fetchWeatherData(2150, 'Syndey', true); //model development, statistical analysis
              // Move into new page
              // ignore: use_build_context_synchronously
              navigateToGraph(context);
            },
            tooltip: 'Increment',
            heroTag: 'dev option',
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton( // TODO# development: button enables in-depth look in models and model selection
            onPressed: () {
              Model();
            },
            tooltip: 'Second Button',
            heroTag: 'test option',
            child: const Icon(Icons.pause_circle),
          ),
        ],
      ),
    );
  }
}
