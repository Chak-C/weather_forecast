//note this does not work on terminal, require emulator
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:weather_forecast/data_analysis/flutter_tflite_modelling.dart';

//testing variables
final _input = [
  [226.0,207.0,200.5,218.0,209.0,203.0,183.0,206.0,224.0]
];

var _testingoutput = List.filled(1, 0).reshape([1,1]);

//prediction test
void main() {
  Model2 model = Model2();
  model.loadAndPredict(0, _input, _testingoutput);
}