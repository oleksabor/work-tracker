import 'package:work_tracker/classes/init_get.dart';
import 'package:work_tracker/views/main_items_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl_standalone.dart';
import 'package:overlay_support/overlay_support.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //https://stackoverflow.com/a/68911879/940182
  await findSystemLocale();
  configureDependencies();
  runApp(MyApp());
}

// flutter gen-l10n --template-arb-file=app_en.arb
// dart pub global run intl_utils:generate

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
        child: MaterialApp(
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
    ));
  }
}
