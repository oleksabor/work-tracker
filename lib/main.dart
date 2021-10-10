import 'package:work_tracker/views/kind_view.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String get title => 'Work tracker';
  String get titleApp => 'Work tracker application';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: titleApp,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateTitle: (BuildContext ctx) => "helloWorld",
      home: KindPage(title: title),
    );
  }
}
