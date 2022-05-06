import 'package:imageclassification/oneclass.dart';

class OneClassVgg extends OneClass {
  OneClassVgg({int numThreads: 1}) : super(numThreads: numThreads);

  @override
  String get modelName => 'one_class_vgg.tflite';
}
