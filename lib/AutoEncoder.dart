import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

abstract class AutoEncoder {
  late Interpreter _interpreter;
  late InterpreterOptions _interpreterOptions;

  var logger = Logger();

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorImage _tensorImage;
  late TensorBuffer _outputBuffer;

  late TfLiteType _inputType;
  late TfLiteType _outputType;

  // late SequentialProcessor<TensorBuffer> _probabilityProcessor;

  String get modelName;

  AutoEncoder({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }

    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter =
      await Interpreter.fromAsset(modelName, options: _interpreterOptions);
      print('Interpreter Created Successfully');

      _inputShape = _interpreter.getInputTensor(0).shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;
      _inputType = _interpreter.getInputTensor(0).type;
      _outputType = _interpreter.getOutputTensor(0).type;

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      // _probabilityProcessor =
      //     TensorProcessorBuilder().add(DequantizeOp(0, 1 / 255.0)).build();

    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  TensorImage _preProcess(TensorImage inputImage) {
    int cropSize = min(inputImage.height, inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(32, 32, ResizeMethod.BILINEAR))
        .add(QuantizeOp(0, 255.0))
        .build()
        .process(inputImage);
  }

  bool predict(Image image) {
    _tensorImage = TensorImage(_inputType);
    _tensorImage.loadImage(image);
    _tensorImage = _preProcess(_tensorImage);

    print("Image Loaded");

    _interpreter.run(_tensorImage.buffer, _outputBuffer.getBuffer());

    List inputList = _tensorImage.buffer.asFloat32List();
    List<double> outputList = _outputBuffer.getDoubleList();

    print("Image Predicted");

    double squareSum = 0;
    if(inputList.length == outputList.length) {
      for(int i = 0; i < inputList.length; i++) {
        squareSum += pow(inputList[i] - outputList[i], 2);
      }
      double mse = squareSum / inputList.length;

      print(mse);

      if (mse >= 0.1) {
        print("not a cash");
        return false;
      }
    }
    return true;
  }

  void close() {
    _interpreter.close();
  }
}

MapEntry<String, double> getTopProbability(Map<String, double> labeledProb) {
  var pq = PriorityQueue<MapEntry<String, double>>(compare);
  pq.addAll(labeledProb.entries);

  return pq.first;
}

int compare(MapEntry<String, double> e1, MapEntry<String, double> e2) {
  if (e1.value > e2.value) {
    return -1;
  } else if (e1.value == e2.value) {
    return 0;
  } else {
    return 1;
  }
}
