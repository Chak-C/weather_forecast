import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class Model2 {
  final _modelFile = 'assets/models/py_model_sample.tflite';

  late tfl.Interpreter _interpreter; //first model
  //late tfl.Interpreter interpreter2; //second model 

  //tests, move to tests folder
  var input = [
    [226.0,207.0,20.05,218.0,209.0,203.0,183.0,206.0,224.0]
  ];
    
  var _testingoutput = List.filled(1, 0).reshape([1,1]);

  dynamic loadAndPredict(int option, var sequence, var output) async {
    switch(option) {
      case 0:
        await _loadModel();
        return _predictM1(sequence, _testingoutput);
      default:
        '';
    }
    
  }

  Future _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset(_modelFile);
      print('Model loaded.');
    } catch (e) {
      print('Failed to load model. $e');
    }
  }

  dynamic _predictM1(var sequence, var output) {
    //dynamic type to float32 type
    //var inputBuffer = Float32List.fromList(sequence.expand((e) => e).toList());
    _interpreter.allocateTensors();
    _interpreter.run(sequence,output);
    return output[0][0];
  }
}