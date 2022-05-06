import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imageclassification/classifier.dart';
import 'package:imageclassification/classifier_quant.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

import 'oneclass.dart';
import 'oneclass_vgg.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Classifier _classifier;
  late OneClass _oneClass;

  final FlutterTts flutterTts = FlutterTts();

  late  PageController  _controller ;

  var logger = Logger();

  File? _image;
  final picker = ImagePicker();

  Image? _imageWidget;

  img.Image? fox;

  Category? category;

  String result = "";

  String result2 = "";

  List<String> reslutList = [];

  @override
  void initState() {
   
    super.initState();
    _classifier = ClassifierQuant();
    _oneClass = OneClassVgg();
    _controller = PageController(
      initialPage: 0,
    );

  }

  Future getImageCamera() async {
    print("pressed camera");
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile!.path);
      _imageWidget = Image.file(_image!);
    });

    _predict();
  }

 
  void _predict() async {
    print("pressed predict");
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;

    bool cashPredict = _oneClass.predict(imageInput);

    if (!cashPredict) {
      _speakValue("");
      return;
    } else {
      _speakValue("cash");
    }
  }


    _speakValue(String value) async {
      if (value == "cash") {
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(pattern: [100, 1000], intensities: [1, 255]);
        }
        await flutterTts.speak(
            "Currency Note detected");
      } else {
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(pattern: [100, 100], intensities: [1, 255]);
        }
        await flutterTts.speak("can't identify the currency note. please try again");
      }
    }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: PageView(
      controller: _controller,
      onPageChanged: _speakPage,
      children: <Widget>[
        Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          _image == null
              ? Container(
                  height: height / 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text(
                      'No image selected.',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                )
              : Container(
                  height: height / 2,
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 2),
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: _imageWidget,
                ),
          Container(
              height: height / 2,
              width: width,
              // margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: RaisedButton(
                onPressed: () => getImageCamera(),
                child: Text('Click Here To Select Image From Camera',
                    style: TextStyle(fontSize: 30)),
                textColor: Colors.white,
                color: Colors.blueAccent,
                // padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
              )),
        ]),
        Container(
            child: Center(
                child: SizedBox.expand(
                    child: FlatButton(
                        highlightColor: Color(0xFFA8DEE0),
                        splashColor: Color(0xffF9E2AE),
                        onPressed: () => { _predict()},
                        child: Center(
                          child: Text("Click center to get currency value",
                              style: TextStyle(
                                  fontSize: 27.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        )))),
            color: Colors.blueAccent),
        
      ],
      scrollDirection: Axis.horizontal,
      pageSnapping: true,
      physics: BouncingScrollPhysics(),
    ));
  }

  _speakPage(int a) async {
    if (a == 0) {
      await flutterTts.speak(
          "Live Currency detection. Click bottom to capture the photo.After that press bottom center and bottom right");
    } else if (a == 1) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(amplitude: 128, duration: 1000);
      }
      await flutterTts.speak("Click center to get currency value");
    } 
     


  }
}
