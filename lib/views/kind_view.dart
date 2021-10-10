import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/views/work_item_page.dart';

class KindPage extends StatefulWidget {
  const KindPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _KindPageState createState() => _KindPageState();
}

class _KindPageState extends State<KindPage> {
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

  Widget _buildRow(WorkKindToday i) {
    var tw = i.todayWork;
    var last = tw != null && tw.isNotEmpty ? tw.last : null;

    var subtitle = last == null ? "not now" : '${last.created} [${last.qty}]';

    return ListTile(
      title: Text(i.kind.title),
      subtitle: Text(subtitle),
    );
  }
}
