import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_v2/tflite_v2.dart';

//depreciated class, use model2 instead
class Model {
  final _modelFile = 'assets/models/py_model_sample.tflite';

  Model() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadModel();
    _predict();
  }

  Uint8List float32ListToUint8List(Float32List floatList) {
    var convertedList = Uint8List(floatList.length * Float32List.bytesPerElement);
    var buffer = Float32List.view(convertedList.buffer);
    buffer.setAll(0, floatList);
    return convertedList;
  }

  Future _loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: _modelFile,
        labels: ""
      );
      print(res);
    } on PlatformException catch (e) {
      print('Failed to load model. $e');
    }
  }

  // potential params
  // lookback - sequences in past required (fixed for model)
  // delay - future predicted (fixed for model)
  Future<dynamic> _predict() async {
    List<double> input = [226.0,207.0,205.0,218.0,209.0,203.0,183.0,206.0,224.0];
    var inp = Float32List.fromList(input);

    var output = await Tflite.runModelOnBinary(binary: float32ListToUint8List(inp));

    return output;
  }
}