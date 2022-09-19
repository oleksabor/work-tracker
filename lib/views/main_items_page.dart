import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:work_tracker/classes/init_get.dart';
import 'package:work_tracker/classes/notify_model.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/views/charts_page.dart';
import 'package:work_tracker/views/config_page.dart';
import 'package:work_tracker/views/pop_menu_data.dart';
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
  final WorkViewModel _model = WorkViewModel();
  Timer? timer;

  late ThemeData? themeData;

  void workItemAdd(BuildContext context, WorkKindToday kToday) async {
    var wi = WorkItem.i(kToday.kind.key);
    var todayWork = kToday.todayWork;
    if (todayWork != null && todayWork.isNotEmpty) {
      wi.qty = todayWork.last.qty;
      wi.weight = todayWork.last.weight;
    }
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => WorkItemPage(item: wi, title: kToday.kind.title)),
    );
    if (res != null) {
      var item = _model.store(res);
      kToday.todayWork ??= [];
      setState(() {
        kToday.todayWork?.add(item);
      });
      await notify();
    }
  }

  Future notify() async {
    var configModel = getIt<ConfigModel>();
    var config = await configModel.load();
    if (config.notify.playAfterNewResult) {
      NotifyModel.playSchedule(config.notify);
      var min = config.notify.delay / 60;
      var sec = config.notify.delay % 60;

      showSimpleNotification(
        Text(t.notificationScheduled(min.toInt(), sec)),
        background: themeData?.primaryColor ?? Colors.blue,
        position: NotificationPosition.bottom,
      );
    }
  }

  void workItemsView(BuildContext context, WorkKindToday kind) async {
    var d = DateTime.now();
    if (kind.todayWork != null && kind.todayWork!.isNotEmpty) {
      d = kind.todayWork!.last.created;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) =>
              WorkItemsView(date: d, kind: kind.kind, model: _model)),
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

  static const tagDebug = "Debug";
  static const tagChart = "Charts";
  static const tagSettings = "Settings";
  static const tagEdit = "edit";
  static const tagDelete = "delete";
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

    kindPopup = MenuContext<String, WorkKindToday>([
      PopupMenuData(tagEdit, t.menuEdit, icon: Icons.edit, onClick: editKind),
      PopupMenuData(tagDelete, t.menuDelete,
          icon: Icons.delete, onClick: deleteKind)
    ]);

    return Scaffold(
        appBar: AppBar(
          title: Text(t.titleWin),
          actions: <Widget>[getMainContext(menuTags)],
        ),
        body: Column(mainAxisSize: MainAxisSize.max, children: [
          Flexible(
              flex: 9,
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [getVersionText(), const SizedBox(width: 10)],
          )
        ]));
  }

  ListView getItemsListView(List<dynamic>? items) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(10.0),
      itemCount: items!.length,
      itemBuilder: (ctx, i) {
        return GestureDetector(
            onLongPress: () =>
                kindPopup.show(ctx, items[i], kindPopup.tapPosition),
            onTapDown: kindPopup.storePosition,
            onTap: () => workItemsView(ctx, items[i]),
            child: _buildRow(ctx, items[i]));
      },
    );
  }

  late MenuContext<String, WorkKindToday> kindPopup;

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
      todayWork = loadWorkFor(DateTime.now());
    });
  }
}
