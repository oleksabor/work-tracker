import 'package:flutter/material.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/doc_dir.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({Key? key}) : super(key: key);

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

  Future moveDb() async {
    var vm = WorkViewModel();
    if (await Permission.storage.request().isGranted) {
      var externalDir = await vm.getExternalDir();

      if (externalDir != null) await vm.moveDb2Dir(externalDir.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t!.titleWinDebug),
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Text(t.timeFormatCap),
              const SizedBox(width: 50),
              Text(DateMethods.timeFormat.format(DateTime.now()))
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Text(t.dateFormatCap),
              const SizedBox(width: 50),
              Text(DateTime.now().asStringTime())
            ]),
            TextButton(
              onPressed: moveDb,
              child: Text(t.moveDb2ExtCap),
            )
          ]),
    );
  }
}
