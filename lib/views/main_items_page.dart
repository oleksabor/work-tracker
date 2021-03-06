import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/views/charts_page.dart';
import 'package:work_tracker/views/config_page.dart';
import 'package:work_tracker/views/work_item_page.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:work_tracker/views/work_items_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'debug_page.dart';
import 'lifecycle_watcher_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_logger/simple_logger.dart';

/// main app page
class MainItemsPage extends StatefulWidget {
  const MainItemsPage({Key? key}) : super(key: key);

  @override
  _MainItemsPageState createState() => _MainItemsPageState();
}

/// main app page state
class _MainItemsPageState extends LifecycleWatcherState<MainItemsPage> {
  final WorkViewModel _model = WorkViewModel();
  Timer? timer;

  void workItemAdd(BuildContext context, WorkKindToday kToday) async {
    var wi = WorkItem.i(kToday.kind.key);
    var todayWork = kToday.todayWork;
    if (todayWork != null && todayWork.isNotEmpty) {
      wi.qty = todayWork.last.qty;
      wi.weight = todayWork.last.weight;
    }
    var res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => WorkItemPage(item: wi)),
    );
    if (res != null) {
      var item = _model.store(res);
      kToday.todayWork ??= [];
      setState(() {
        kToday.todayWork?.add(item);
      });
    }
  }

  void workItemsView(BuildContext context, WorkKindToday kind) async {
    var d = DateTime.now();
    if (kind.todayWork != null && kind.todayWork!.isNotEmpty) {
      d = kind.todayWork!.last.created;
    }
    var items = _model.loadItemsByDate(kind.kind, d);
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => WorkItemsView(
              date: d, kind: kind.kind.title, items: items, model: _model)),
    );
  }

  late String systemLocale;
  late List<Locale> currentSystemLocales;

  late Future<List<WorkKindToday>> todayWork;

  // Here we read the current locale values
  void setCurrentLocale() {
    currentSystemLocales = WidgetsBinding.instance.window.locales;
    systemLocale = Platform.localeName;
    initializeDateFormatting(systemLocale, null);
  }

  @override
  void initState() {
    setCurrentLocale();
    timer = Timer.periodic(
        const Duration(seconds: 30), (Timer t) => setState(() {}));
    todayWork = loadWorkFor(DateTime.now());
    super.initState();
  }

  @override
  void dispose() {
    _model.dispose();
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  Future<List<WorkKindToday>> loadWorkFor(DateTime when) async {
    return _model.loadWork(when);
  }

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    return version;
  }

  final menuTags = [tagChart, tagDebug, tagSettings];
  static const tagDebug = "Debug";
  static const tagChart = "Charts";
  static const tagSettings = "Settings";
  final logger = SimpleLogger();

  void handleClick(String tag) async {
    if (kDebugMode) {
      logger.fine('menu $tag');
    }
    switch (tag) {
      case tagDebug:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => DebugPage.m(model: _model)),
        );
        break;
      case tagChart:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => ChartItemsView(_model)),
        );
        break;
      case tagSettings:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => const ConfigPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    DateMethods.locale = Localizations.localeOf(context);
    DateMethods.mediaQueryData = MediaQuery.of(context);
    var t = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(t?.titleWin ?? "failed to localize"),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return menuTags.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                  flex: 10,
                  child: FutureBuilder<List>(
                    future: todayWork,
                    initialData: [],
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? getItemsListView(snapshot.data)
                          : const Center(
                              child: CircularProgressIndicator(),
                            );
                    },
                  )),
              Row(
                children: [getVersionText(), const SizedBox(width: 10)],
                mainAxisAlignment: MainAxisAlignment.end,
              )
            ])
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _incrementCounter,
        //   tooltip: 'add',
        //   child: Icon(Icons.add),
        // ), // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  ListView getItemsListView(List<dynamic>? items) {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: items!.length,
      itemBuilder: (ctx, i) {
        return GestureDetector(
            onLongPress: () => workItemAdd(ctx, items[i]),
            onTap: () => workItemsView(ctx, items[i]),
            child: _buildRow(ctx, items[i]));
      },
    );
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

  String dateAsString(DateTime? value) {
    if (value == null) {
      return "-";
    }
    return value.smartString();
  }

  Widget _buildRow(BuildContext ctx, WorkKindToday i) {
    var tw = i.todayWork;
    var last = tw != null && tw.isNotEmpty ? tw.last : null;

    var dateStr = dateAsString(last?.created);

    var subtitle = last == null ? "-" : '$dateStr [${last.qty}]';

    return ListTile(
        title: Text(i.kind.title),
        subtitle: Text(subtitle),
        trailing: IconButton(
          onPressed: () {
            workItemAdd(ctx, i);
          },
          color: Theme.of(context).iconTheme.color,
          icon: const Icon(Icons.add),
        ));
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
      loadWorkFor(DateTime.now());
    });
  }
}
