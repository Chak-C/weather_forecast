import 'package:weather_forecast/csv_processes.dart/csv_class.dart';

List<DataEntry> extractColumns(LoadedCSV curcsv, int columnTime, int columnVar) {
  final dataList = curcsv.currentCSV.sublist(1, curcsv.currentCSV.length - 1); //exclude first (header) and last (empty);

  final list = dataList.map((row) {
    DateTime date = DateTime.parse(row[columnTime]);
    double variable = double.parse(row[columnVar]);
    return DataEntry(date, variable);
  }).toList();
  return list;
}
  
// Class containing the time and variable measured.
class DataEntry {
  DateTime date;
  double variable;

  DataEntry(this.date, this.variable);
}
