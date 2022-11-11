import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:work_tracker/classes/communicator.dart';
import 'package:work_tracker/classes/items_list/list_bloc.dart';
import 'package:work_tracker/classes/notify_model.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_kind_today.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/views/charts_page.dart';
import 'package:work_tracker/views/config_page.dart';
import 'package:work_tracker/views/items_list_view.dart';
import 'package:work_tracker/views/work_item_page.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:work_tracker/views/work_items_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:work_tracker/views/work_kind_page.dart';
import 'debug_page.dart';
import 'lifecycle_watcher_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:overlay_support/overlay_support.dart';

part 'main_items_context_menu.dart';

/// main app page
class MainItemsPage extends StatefulWidget {
  const MainItemsPage({Key? key}) : super(key: key);

  @override
  _MainItemsPageState createState() => _MainItemsPageState();
}

/// main app page state
class _MainItemsPageState extends LifecycleWatcherState<MainItemsPage> {
  // final WorkViewModel _model = WorkViewModel();
  Timer? timer;

  late ThemeData? themeData;

  void showNotification(bool success, String message) {
    var colorTheme = themeData?.primaryTextTheme.titleMedium;
    var colorTxt = colorTheme?.color ?? colorTheme?.foreground?.color;
    colorTxt = colorTxt ?? Colors.grey;

    var colorBack = success ? themeData?.primaryColor : themeData?.errorColor;
    showSimpleNotification(
      Text(message),
      background: colorBack,
      foreground: colorTxt,
      position: NotificationPosition.bottom,
    );
  }

  var twoDig = NumberFormat("00");

  late String systemLocale;
  late List<Locale> currentSystemLocales;

  //late Future<List<WorkKindToday>> todayWork;

  // Here we read the current locale values
  void setCurrentLocale() {
    currentSystemLocales = WidgetsBinding.instance.window.locales;
    systemLocale = Platform.localeName;
    initializeDateFormatting(systemLocale, null);
  }

  Communicator com = Communicator();

  comNotification(dynamic data) {
    var message = "a notification";
    if (data is String) {
      message = data;
    }
    if (kDebugMode) {
      print("comNotification: $message");
    }
    showNotification(true, message);
  }

  @override
  void initState() {
    setCurrentLocale();
    var vm = RepositoryProvider.of<WorkViewModel>(context);
    timer = Timer.periodic(
        const Duration(seconds: 30), (Timer t) => setState(() {}));
    // loadWork();
    com.init(comNotification);
    super.initState();
  }

  // void loadWork() {
  //   todayWork = loadWorkFor(DateTime.now());
  // }

  @override
  void dispose() {
    // _model.dispose();
    com.close();
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  // Future<List<WorkKindToday>> loadWorkFor(DateTime when) async {
  //   return _model.loadWork(when);
  // }

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    return version;
  }

  static const tagDebug = "Debug";
  static const tagChart = "Charts";
  static const tagSettings = "Settings";
  static const tagAddKind = "addKind";
  final logger = SimpleLogger();
  late AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    DateMethods.locale = Localizations.localeOf(context);
    DateMethods.mediaQueryData = MediaQuery.of(context);
    themeData = Theme.of(context);

    t = AppLocalizations.of(context)!;
    final menuTags = {
      tagAddKind: t.menuAddKind,
      tagChart: t.menuCharts,
      tagDebug: t.menuDebug,
      tagSettings: t.menuSettings
    };

    return Scaffold(
        appBar: AppBar(
          title: Text(t.titleWin),
          actions: <Widget>[getMainContext(menuTags, context)],
        ),
        body: Column(mainAxisSize: MainAxisSize.max, children: [
          Flexible(flex: 9, child: ItemsListView()),
          // Row(children: [
          //   TextButton(
          //     child: const Text("communicator test"),
          //     onPressed: () {
          //       Communicator.send("test from UI");
          //     },
          //   )
          // ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [getVersionText(), const SizedBox(width: 10)],
          )
        ]));
  }

  FutureBuilder<String> getVersionText() {
    return FutureBuilder<String>(
        future: getAppVersion(),
        initialData: "version",
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Text(snapshot.data!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary))
              : const Center(child: CircularProgressIndicator());
        });
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    setState(() {
      //loadWork();
    });
  }
}
