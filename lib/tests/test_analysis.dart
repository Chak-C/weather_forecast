import 'package:weather_forecast/data_analysis/analysis_variable.dart';
import 'package:weather_forecast/tests/test_csv.dart';

import '../csv_processes.dart/csv_class.dart';

void main() {
  LoadedCSV test = testdata();
  List<DataEntry> temp = extractColumns(test,0,4);
  print(temp);
}