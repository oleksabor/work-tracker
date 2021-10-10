import 'package:fl_starter/classes/work_view_model.dart';
import 'package:flutter/material.dart';

class KindPage extends StatefulWidget {
  KindPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _KindPageState createState() => _KindPageState();
}

class _KindPageState extends State<KindPage> {
  WorkViewModel _model = new WorkViewModel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder<List>(
        future: _model.loadWork(DateTime.now()),
        initialData: [],
        builder: (context, snapshot) {
          return snapshot.hasData
              ? new ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    return _buildRow(snapshot.data![i]);
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
    return new ListTile(
      title: new Text(i.kind.title),
      subtitle: new Text(i.todayWork == null || i.todayWork!.length == 0
          ? "not now"
          : i.todayWork!.first.created.toString()),
    );
  }
}
