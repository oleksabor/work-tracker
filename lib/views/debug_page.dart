import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/debug_model.dart';
import 'package:work_tracker/classes/doc_dir.dart';
import 'package:work_tracker/classes/init_get.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class DebugPage extends StatefulWidget {
  final WorkViewModel model;
  const DebugPage.m({Key? key, required this.model}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DebugPageState();
  }
}

class DebugPageState extends State<DebugPage> {
  @override
  void initState() {
    super.initState();
    model = getIt<DebugModel>();
  }

  Widget createColumnDir(DirData data) {
    var items = data.toList();
    var res = ListView.builder(
        itemCount: items.length,
        itemBuilder: (c, i) {
          return ListTile(
            title: Text(items[i].title),
            subtitle: Text(
              items[i].path ?? "-",
              overflow: TextOverflow.clip,
            ),
            isThreeLine: true,
          );
        });

    return res;
  }

  Widget asRow(String title, String value) {
    return Row(
        children: [Text(title), const SizedBox(width: 50), asText(value)]);
  }

  Widget asText(String value) {
    return Expanded(
      child: Text(value, overflow: TextOverflow.fade),
    );
  }

  Widget createKindList(List<WorkKindToday> items) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(10.0),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        return ListTile(
            title: Text(items[i].kind.title),
            subtitle: Text(
                "id:${items[i].kind.kindId} count:${items[i].todayWork?.length}"));
      },
    );
  }

  late DebugModel model;
  int? dbItemsUpgraded;

  Future exportTo() async {
    if (!await requestStoragePermission()) return;
    var downloads = await DirData.getAppDocumentsPath();
    if (downloads == null) return;
    await showBusy(context, () async {
      var fn = DateFormat("yyyyMMdd-kkmm").format(DateTime.now());
      var src = await model.groupByKinds();
      var fileName = "$downloads/streetWorkouts$fn.json";
      await model.exportJson(fileName, src);
      await model.share(fileName);
    }, title: "export data");
  }

  Future<bool> requestStoragePermission() async {
    var permission = Permission.storage;
    var status = await permission.status;
    debugPrint("storage permission: $status");
    if (status != PermissionStatus.granted) {
      await permission.request();
      if (!await permission.status.isGranted) {
        debugPrint("no permission has been granted");
        return false;
      }
    }
    return true;
  }

  Future importFrom() async {
    if (!await requestStoragePermission()) return;
    var downloads = await FilePicker.platform
        .pickFiles(initialDirectory: await DirData.getAppDocumentsPath());
    // var downloads = await DirData.getDownloads();
    if (downloads == null || !await requestStoragePermission()) return;
    // downloads = "$downloads/streetWorkoutsExport.json";
    await showBusy(context, () async {
      //var fn = DateFormat("yyyyMMdd-kkmm").format(DateTime.now());
      var res = await model.importJson(downloads!.files.single.path!);
      await model.import2db(res);
    }, title: "importing");
  }

  List<Widget> createTabKinds(BuildContext context, WorkViewModel workModel) {
    return <Widget>[
      // kinds
      Column(children: [
        Flexible(
            flex: 9,
            child: FutureBuilder<List<WorkKindToday>>(
              future: model.groupByKinds(),
              builder: (c, s) => s.hasData
                  ? createKindList(s.data!)
                  : const CircularProgressIndicator(),
            )),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          TextButton(
            onPressed: () async {
              await exportTo();
            },
            child: Text("export to ..."),
          ),
          TextButton(
            onPressed: () async {
              await importFrom();
              setState(() {}); // should re-read items has been exported
            },
            child: Text("import from ..."),
          ),
        ]),
        Flexible(
            flex: 1,
            child: FutureBuilder<List<WorkItem>>(
              future: workModel.loadItems(),
              builder: (c, s) => s.hasData
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                          const Text("work items count"),
                          const SizedBox(width: 50),
                          Text("${s.data!.length}")
                        ])
                  : const CircularProgressIndicator(),
            )),
      ]),
    ];
  }

  List<Widget> createTabDirs() {
    return <Widget>[
      // directories
      Column(children: [
        Expanded(
            child: FutureBuilder<DirData>(
          future: DirData.loadDirectories(),
          builder: (c, s) => s.hasData
              ? createColumnDir(s.data!)
              : const CircularProgressIndicator(),
        ))
      ]),
    ];
  }

  List<Widget> createTabFormats(WorkViewModel workModel) {
    var t = AppLocalizations.of(context);
    return <Widget>[
      //formats
      Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text(t!.timeFormatCap),
          const SizedBox(width: 50),
          Text(DateMethods.timeFormat.format(DateTime.now()))
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text(t.dateFormatCap),
          const SizedBox(width: 50),
          Text(DateTime.now().asStringTime())
        ]),
        // TextButton(
        //   onPressed: () async {
        //     if (await Permission.storage.request().isGranted) {
        //       await model.moveDb();
        //     }
        //   },
        //   child: Text(t.moveDb2ExtCap),
        // ),
        // TextButton(
        //   onPressed: () => model.closeDb(workModel),
        //   child: Text("close db"),
        // ),
        // TextButton(
        //   onPressed: () async {
        //     showDialog(
        //         context: context,
        //         builder: (BuildContext context) {
        //           return Column(children: const [
        //             Center(
        //               child: CircularProgressIndicator(),
        //             ),
        //             Center(child: Text("please wait")),
        //           ]);
        //         });
        //     dbItemsUpgraded = await model.upgradeDb(workModel);
        //     if (kDebugMode) {
        //       await Future.delayed(const Duration(seconds: 1));
        //     }
        //     if (!mounted) return;
        //     Navigator.pop(context);
        //     setState(() {});
        //   },
        //   child: Text("upgrade db ($dbItemsUpgraded)"),
        // ),
        TextButton(
          onPressed: () async {
            showDialogIndicator(context);
            await seedDummyData(workModel);
            if (kDebugMode) {
              await Future.delayed(const Duration(seconds: 1));
            }
            Navigator.pop(context);
          },
          child: Text("seed dummy data"),
        ),
      ]),
    ];
  }

  Future showBusy(BuildContext context, Future Function() action,
      {String title = "please wait"}) async {
    showDialogIndicator(context, title: title);
    try {
      await action();
    } finally {
      Navigator.pop(context);
    }
  }

  showDialogIndicator(BuildContext context, {String title = "please wait"}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Column(children: [
            Center(
              child: CircularProgressIndicator(),
            ),
            Center(child: Text(title)),
          ]);
        });
  }

  Future<void> seedDummyData(WorkViewModel model) async {
    var kinds = await model.loadKinds();
    var n = DateTime.now();
    var dates = [
      n,
      n.add(Duration(days: -4)),
      n.add(Duration(days: -8)),
      n.add(Duration(days: -14))
    ];

    var repeat = 3;
    var random = Random();
    for (var k in kinds) {
      for (var d in dates) {
        var q = 0;
        while (q++ < repeat) {
          var wi = WorkItem.i(k.kindId)
            ..created = d.add(Duration(days: -k.kindId + 1))
            ..qty = random.nextInt(30) + 1;
          if (random.nextInt(10) > 4) {
            wi.weight = random.nextInt(10).toDouble();
          }
          model.store(wi);
        }
      }
    }
  }

  late Map<String, List<Widget>> tabs;

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);
    var workModel = WorkViewModel();
    tabs = {
      "Data": createTabKinds(context, workModel),
      "Dirs": createTabDirs()
    };
    if (kDebugMode) {
      tabs["Formats"] = createTabFormats(workModel);
    }

    var tabTitles = tabs.keys.map((c) => Text(c)).cast<Widget>().toList();
    var tabPages = <Widget>[];
    for (var p in tabs.values) {
      tabPages.addAll(p);
    }
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(t!.titleWinDebug),
            bottom: TabBar(
              tabs: tabTitles,
            ),
          ),
          body: TabBarView(children: tabPages),
        ));
  }
}
