import 'package:flutter/material.dart';
import 'package:work_tracker/classes/doc_dir.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: Center(
          child: FutureBuilder<DirData>(
        future: DirData.loadDirectories(),
        builder: (c, s) => s.hasData
            ? createColumnDir(s.data!)
            : const Center(
                child: CircularProgressIndicator(),
              ),
      )),
    );
  }
}
