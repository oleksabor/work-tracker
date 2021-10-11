import 'dart:io';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/views/work_item_page.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:intl/date_symbol_data_local.dart';

class KindPage extends StatefulWidget {
  final String defaultLocale;
  const KindPage({Key? key, required this.title, this.defaultLocale = "en-US"})
      : super(key: key);

  final String title;

  @override
  _KindPageState createState() => _KindPageState();
}

class _KindPageState extends State<KindPage> with WidgetsBindingObserver {
  final WorkViewModel _model = WorkViewModel();

  void workItemEdit(BuildContext context, WorkKindToday kToday) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => WorkItemPage(item: WorkItem.k(kToday.kind.title))),
    );
    if (res != null) {
      var item = _model.store(res);
      kToday.todayWork ??= [];
      setState(() {
        kToday.todayWork?.add(item);
      });
    }
  }

  late String systemLocale;
  late List<Locale> currentSystemLocales;

  // Here we read the current locale values
  void setCurrentLocale() {
    currentSystemLocales = WidgetsBinding.instance!.window.locales;
    systemLocale = Platform.localeName;
    initializeDateFormatting(systemLocale, null);
  }

  @override
  void initState() {
    // This is run when the widget is first time initialized
    WidgetsBinding.instance!.addObserver(this); // Subscribe to changes
    setCurrentLocale();
    super.initState();
  }

  Future<List<WorkKindToday>> loadWorkFor(DateTime when) async {
    return _model.loadWork(when);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder<List>(
        future: loadWorkFor(DateTime.now()),
        initialData: [],
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, i) {
                    return GestureDetector(
                        onTap: () => workItemEdit(ctx, snapshot.data![i]),
                        child: _buildRow(snapshot.data![i]));
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'add',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  String dateAsString(DateTime? value) {
    if (value == null) {
      return "-";
    }
    return value.smartString();
  }

  Widget _buildRow(WorkKindToday i) {
    var tw = i.todayWork;
    var last = tw != null && tw.isNotEmpty ? tw.last : null;

    var dateStr = dateAsString(last?.created);

    var subtitle = '$dateStr [${last?.qty ?? 0}]';

    return ListTile(
      title: Text(i.kind.title),
      subtitle: Text(subtitle),
    );
  }
}
