import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/debug_model.dart';
import 'package:work_tracker/classes/doc_dir.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';

class DebugPage extends StatefulWidget {
  final WorkViewModel model;
  const DebugPage.m({Key? key, required this.model}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DebugPageState();
  }
}

class DebugPageState extends State<DebugPage> {
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

  Widget createKindList(List<WorkKind> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        return ListTile(
            title: Text(items[i].title), subtitle: Text("id:${items[i].key}"));
      },
    );
  }

  DebugModel model = DebugModel();
  int? dbItemsUpgraded;

  List<Widget> createSwipes(BuildContext context) {
    var workModel = WorkViewModel();
    var t = AppLocalizations.of(context);
    // three columns for three tabs (swipes)
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
      // kinds
      Column(children: [
        Flexible(
            flex: 9,
            child: FutureBuilder<List<WorkKind>>(
              future: workModel.loadKinds(),
              builder: (c, s) => s.hasData
                  ? createKindList(s.data!)
                  : const CircularProgressIndicator(),
            )),
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
        TextButton(
          onPressed: () async {
            if (await Permission.storage.request().isGranted) {
              await model.moveDb();
            }
          },
          child: Text(t.moveDb2ExtCap),
        ),
        TextButton(
          onPressed: () => model.closeDb(workModel),
          child: Text("close db"),
        ),
        TextButton(
          onPressed: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Column(children: const [
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    Center(child: Text("please wait")),
                  ]);
                });
            dbItemsUpgraded = await model.upgradeDb(workModel);
            if (kDebugMode) {
              await Future.delayed(const Duration(seconds: 5));
            }
            if (!mounted) return;
            Navigator.pop(context);
          },
          child: Text("upgrade db ($dbItemsUpgraded)"),
        ),
        TextButton(
          onPressed: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Column(children: const [
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    Center(child: Text("please wait")),
                  ]);
                });
            await seedDummyData(workModel);
            if (kDebugMode) {
              await Future.delayed(const Duration(seconds: 3));
            }
            Navigator.pop(context);
          },
          child: Text("seed dummy data"),
        ),
      ]),
    ];
  }

  Future<void> seedDummyData(WorkViewModel model) async {
    var kinds = await model.loadKinds();
    var n = DateTime.now();
    var dates = [
      n,
      n.add(Duration(days: -4)),
      n.add(Duration(days: -8)),
      n.add(Duration(days: 14))
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

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(t!.titleWinDebug),
            bottom: const TabBar(
              tabs: [
                Tab(text: "Dirs"),
                Tab(text: "Items"),
                Tab(text: "Formats"),
              ],
            ),
          ),
          body: TabBarView(children: createSwipes(context)),
        ));
  }
}
