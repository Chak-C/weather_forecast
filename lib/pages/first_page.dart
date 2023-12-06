import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_forecast/support_widgets/time_series.dart';
import '../main.dart';

class LoadPage extends StatelessWidget {
  const LoadPage({super.key});

  void navigateToSelectionPage(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Placeholder()),
      );
    } catch (e) {
      // Handle and log any errors
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    //final theme = Theme.of(context);

    //final style = theme.textTheme.displayMedium!.copyWith(
    //  color: theme.colorScheme.onPrimary,
    //);
    
    return ChartScreen(csv: appState.dataMonthly);
 }
}