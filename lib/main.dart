import 'package:flutter/material.dart';
import 'package:imageclassification/spash.dart';
 
 

import 'const.dart';
import 'home_screen.dart';
 

void main() => runApp(MaterialApp(
      title: 'GridView Demo',
      home: SplashScreen(),
      theme: ThemeData(
        primarySwatch: Colors.red,
        // accentColor: Color(0xFF761322),
      ),
      routes: <String, WidgetBuilder>{
        SPLASH_SCREEN: (BuildContext context) => SplashScreen(),
        HOME_SCREEN: (BuildContext context) => HomeScreen(),
      },
    ));


