import 'package:work_tracker/views/main_items_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'package:intl/intl_standalone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //https://stackoverflow.com/a/68911879/940182
  await findSystemLocale();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //  theme: ThemeData(),
      darkTheme: ThemeData.dark(), // standard dark theme
      themeMode: ThemeMode.system, // device controls theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (ctgt) {
        return AppLocalizations.of(ctgt)?.titleApp ?? "failed to localize";
      },
      home: const MainItemsPage(),
    );
  }
}
