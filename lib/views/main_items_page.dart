import 'dart:async';
import 'dart:io';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/views/work_item_page.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:work_tracker/views/work_items_view.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'lifecycle_watcher_state.dart';

class MainItemsPage extends StatefulWidget {
  final String defaultLocale;
  const MainItemsPage(
      {Key? key, required this.title, this.defaultLocale = "en-US"})
      : super(key: key);

  final String title;

  @override
  _MainItemsPageState createState() => _MainItemsPageState();
}

class _MainItemsPageState extends LifecycleWatcherState<MainItemsPage> {
  final WorkViewModel _model = WorkViewModel();
  Timer? timer;

  void workItemAdd(BuildContext context, WorkKindToday kToday) async {
    var wi = WorkItem.k(kToday.kind.title);
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
    var allItems = await _model.loadItems();
    var items = _model.filterItemsByKind(allItems, kind.kind.title, d);
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) =>
              WorkItemsView(date: d, kind: kind.kind.title, items: items)),
    );
  }

  late String systemLocale;
  late List<Locale> currentSystemLocales;

  late Future<List<WorkKindToday>> todayWork;

  // Here we read the current locale values
  void setCurrentLocale() {
    currentSystemLocales = WidgetsBinding.instance!.window.locales;
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
    String buildNumber = packageInfo.buildNumber;

    return version + "+" + buildNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
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
                children: [getVersionText()],
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
          color: Theme.of(context).primaryColor,
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
