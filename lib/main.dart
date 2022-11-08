import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_tracker/bootstrapper.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:work_tracker/classes/db_loader.dart';
import 'package:work_tracker/classes/debug_model.dart';
import 'package:work_tracker/classes/log_wrapper.dart';
import 'package:work_tracker/classes/notify_model.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:work_tracker/views/main_items_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl_standalone.dart';
import 'package:overlay_support/overlay_support.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //https://stackoverflow.com/a/68911879/940182
  await findSystemLocale();
  runApp(MyApp());
}

// flutter gen-l10n --template-arb-file=app_en.arb
// dart pub global run intl_utils:generate

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: getProviders(),
        child: OverlaySupport.global(
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
        )));
  }

  static dynamic getProviders() {
    final workModel = WorkViewModel();
    final notify = NotifyModel();
    final dbLoader = DbLoader();
    return [
      RepositoryProvider(create: (_) => dbLoader),
      RepositoryProvider(create: (_) => workModel),
      RepositoryProvider(create: (_) => notify),
      RepositoryProvider(create: (_) => ConfigModel(dbLoader)),
      RepositoryProvider(create: (_) => DebugModel(workModel, dbLoader)),
      RepositoryProvider(
          create: (_) => LogWrapper.getLog(ConfigModel(dbLoader))),
    ];
  }
}
