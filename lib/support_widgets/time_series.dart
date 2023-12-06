
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:weather_forecast/csv_processes.dart/csv_class.dart';
import 'package:weather_forecast/data_analysis/analysis_variable.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({
    super.key,
    required this.csv
  });

  final LoadedCSV csv;

  @override
  Widget build(BuildContext context) {
    final data = extractColumns(csv, 0, 4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Series Chart'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TimeSeriesChart(data)),
            );
          },
          child: const Text('Show Time Series Chart'),
        ),
      ),
    );
  }
}

class TimeSeriesChart extends StatelessWidget {
  final List<DataEntry> data;

  const TimeSeriesChart(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Series Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            // line chart data here
            lineBarsData: [
              LineChartBarData(
                spots: data.map((entry) {
                  return FlSpot(entry.date.millisecondsSinceEpoch.toDouble(), entry.variable);
                }).toList(),
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(show: false),
              ),
            ],
            minY: 0,
            titlesData: FlTitlesData(
              // Configure axis titles
            ),
            borderData: FlBorderData(
              // Configure border data
            ),
            gridData: FlGridData(
              // Configure grid data
            ),
          ),
        ),
      ),
    );
  }
}