import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/doc_dir.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({Key? key, required this.pageTitle}) : super(key: key);
  final String pageTitle;

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
    return Row(children: [Text(title), SizedBox(width: 50), asText(value)]);
  }

  Widget asText(String value) {
    return Expanded(
      child: Text(value, overflow: TextOverflow.fade),
    );
  }

  String get move2SDCaption => "move db to External storage";

  Future moveDb() async {
    var vm = WorkViewModel();
    if (await Permission.storage.request().isGranted) {
      var externalDir = await vm.getExternalDir();

      if (externalDir != null) await vm.moveDb2Dir(externalDir.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
                child: FutureBuilder<DirData>(
              future: DirData.loadDirectories(),
              builder: (c, s) => s.hasData
                  ? createColumnDir(s.data!)
                  : const CircularProgressIndicator(),
            )),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("test time format "),
              Text(DateMethods.timeFormat.format(DateTime.now()))
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("test date format "),
              Text(DateTime.now().asStringTime())
            ]),
            TextButton(
              onPressed: moveDb,
              child: Text(move2SDCaption),
            )
          ]),
    );
  }
}
