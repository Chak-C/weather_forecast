import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:weather_forecast/csv_processes.dart/csv_class.dart';

/// Writes the csv data into a csv file saved at Documents (defaulted space, fixed)
Future<void> saveAsCsv(String csvData) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/weather_data.csv');
    
    await file.writeAsString(csvData);
    print('CSV file saved at: ${file.path}');
  } catch (e) {
    print('Error saving CSV file: $e');
  }
}

Future<String> combineCsvData(List<String> csvDataList) async {
  csvDataList = csvDataList.reversed.toList();
  String combinedCsvData = '';

  for (int i = 0; i < csvDataList.length; i++) {
    final csvData = csvDataList[i].split('\n');
    
    if (i == 0) {
      combinedCsvData += csvData.join('\n');
    } else {
      // Skip the first line (header) for subsequent data sets
      final dataWithoutHeader = csvData.skip(1).join('\n');
      combinedCsvData += dataWithoutHeader;
    }
  }

  return combinedCsvData;
}

/// Output csv (string) to csv object (LoadedCSV)
LoadedCSV stringToListCSV(dynamic csvData) {
  List<String> lines = csvData.split('\n');

  List<List<dynamic>> csvList = [];

  for (String line in lines) {
    List<dynamic> row = line.split(',').map((e) => e.trim().replaceAll('"', '')).toList();
    csvList.add(row);
  }
  return LoadedCSV(currentCSV: csvList);
}