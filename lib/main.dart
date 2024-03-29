import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_tracker/bootstrapper.dart';
import 'package:work_tracker/classes/items_list/list_bloc.dart';
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
        providers: Bootstrapper.getProviders(),
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
          home: BlocProvider(
              create: (ctxt) =>
                  ListBloc(ctxt.read<WorkViewModel>())..add(LoadListEvent()),
              child: const MainItemsPage()),
        )));
  }
}
