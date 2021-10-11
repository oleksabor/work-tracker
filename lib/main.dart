import 'package:work_tracker/views/kind_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //https://stackoverflow.com/a/62825776/940182
  final String defaultSystemLocale = Platform.localeName;
  final List<Locale> systemLocales = WidgetsBinding.instance!.window.locales;
  //https://stackoverflow.com/a/63090616/940182
  initializeDateFormatting(defaultSystemLocale, null);
  runApp(MyApp(defaultSystemLocale, systemLocales));
}

class MyApp extends StatelessWidget {
  final String initialDefaultSystemLocale;
  final List<Locale> initialSystemLocales;

  const MyApp(this.initialDefaultSystemLocale, this.initialSystemLocales);
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
      home: KindPage(title: title, defaultLocale: initialDefaultSystemLocale),
    );
  }
}
