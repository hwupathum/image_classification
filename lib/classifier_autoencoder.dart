import 'package:imageclassification/AutoEncoder.dart';
import 'package:imageclassification/classifier.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class ClassifierAutoencoder extends AutoEncoder {
  ClassifierAutoencoder({int numThreads: 1}) : super(numThreads: numThreads);

  @override
  String get modelName => 'autoencoder.tflite';
}
