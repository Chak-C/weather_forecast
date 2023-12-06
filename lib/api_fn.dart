import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:weather_forecast/csv_processes.dart/csv_class.dart';
import 'package:weather_forecast/csv_processes.dart/csv_filing.dart';
import 'package:weather_forecast/json_process.dart';

Future<LoadedCSV> fetchWeatherData(int days, String city, bool saveIntoCSV) async {
  final List<String> csvDataList = [];
  LoadedCSV csv = LoadedCSV(currentCSV: []);
  const intervalLimit = 365;
  int wantRows = days; //2150, also renaming so variable not confused with parameters

  // Replace 'YOUR_TOKEN_HERE' with your actual NOAA API token
  const apiKey = 'YtPbmcEtlRpVInVJAqxSJqUUbpobQOSp';
  const baseUrl = 'https://www.ncdc.noaa.gov/cdo-web/api/v2/data';

  const stationid = 'GHCND:ASN00066037';
  const field = 'date';
  const type = 'TAVG';

  //TODO make flexible (able to change date range and city)
  var locationId = 'CITY:AS000010'; //default, sydney

  switch(city) {
    case 'Sydney':
      locationId = 'CITY:AS000010';
  }

  // Calculate the number of iterations needed based on wantRows and intervalLimit
  final int iterations = (wantRows / intervalLimit).ceil();

  for (int i = 0; i < iterations; i++) {
    DateTime endDate;
    DateTime startDate;

    if(i == 0) {
      endDate = DateTime.now().subtract(const Duration(days: 2));
      startDate =
        endDate.subtract(Duration(days: wantRows + 2));
    } else {
      endDate = DateTime.now().subtract(Duration(days: i * intervalLimit + 2));
      startDate =
        endDate.subtract(const Duration(days: intervalLimit + 2));
    }

    String sDate = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    String eDate = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    final String apiUrl =
        "$baseUrl?datasetid=GHCND&locationid=$locationId&stationid=$stationid&startdate=$sDate&enddate=$eDate&sortedfield=$field&datatypeid=$type&limit=$intervalLimit";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'token': apiKey},
      );

      if (response.statusCode == 200) {
        // Sucessful API call
        final jsonData = json.decode(response.body);
        // Convert to CSV format
        final csvData = jsonToCsv(jsonData);

        //TODO implment options for csv data
        //Option 1: Save data as a text file
        csvDataList.add(csvData);
        print('Fetched interval $i');
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        return csv;
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  final String combinedCsvData = await combineCsvData(csvDataList);
  
  if(saveIntoCSV) {
    await saveAsCsv(combinedCsvData);
  }

  csv = stringToListCSV(combinedCsvData);
  return csv;
}

Future<void> saveCombinedCsv(List<String> csvDataList) async {
  final combinedCsvData = csvDataList.join('\n');
  await saveAsCsv(combinedCsvData);
}

//sample apiUrl = https://www.ncdc.noaa.gov/cdo-web/api/v2/data?
  //  datasetid=GHCND&
  //  locationid=CITY:AS000010&
  //  stationid=GHCND:ASN00066037&
  //  startdate=2022-11-16&
  //  enddate=2023-11-16&
  //  sortedfield=date&
  //  datatypeid=TAVG&
  //  limit=365