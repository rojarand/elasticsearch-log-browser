
import "package:flutter/material.dart";
import 'features/logbrowsing/view/logbrowser_route.dart';

void main() => runApp(LogBrowserApp());

////// BEGIN OF Log browser App

class LogBrowserApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Log Browser",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color.fromARGB(255, 0xF8, 0xF8, 0xF8),
        textTheme: TextTheme(
            //default font color for Text widget
            bodyText2: TextStyle(color: Color.fromARGB(255, 0x77, 0x77, 0x77)),
            //subtitle1: default font color for TextField widget
            subtitle1: TextStyle(color: Color.fromARGB(255, 0x77, 0x77, 0x77))
        ),
        iconTheme: IconThemeData(color: Color.fromARGB(255, 0x77, 0x77, 0x77), size: 24)
      ),
      home: LogBrowserView()
    );
  }
}

////// END OF Log browser App

