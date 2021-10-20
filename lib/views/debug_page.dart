import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DirData {
  final String appDocuments;
  final String appLibrary;
  String? extStorage;

  DirData(
      {required this.appDocuments,
      required this.extStorage,
      required this.appLibrary});
}

class DebugPage extends StatelessWidget {
  const DebugPage({Key? key, required this.pageTitle}) : super(key: key);
  final String pageTitle;

  Future<DirData> loadDirectories() async {
    var docDir = await getApplicationDocumentsDirectory();
    var libDir;

    var es = await getExternalStorageDirectory();
    return DirData(
        appDocuments: docDir.path,
        extStorage: es?.path,
        appLibrary: libDir == null ? "unsuppored" : libDir.path);
  }

  Column createColumnDir(DirData data) {
    return Column(children: [
      asRow("appDocuments", data.appDocuments),
      asRow("appLibrary", data.appLibrary),
      asRow("extDir", data.extStorage ?? "-"),
    ]);
  }

  Widget asRow(String title, String value) {
    return Row(children: [Text(title), SizedBox(width: 50), asText(value)]);
  }

  Widget asText(String value) {
    return Expanded(
      child: Text(value, overflow: TextOverflow.clip),
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
        future: loadDirectories(),
        builder: (c, s) => s.hasData
            ? createColumnDir(s.data!)
            : const Center(
                child: CircularProgressIndicator(),
              ),
      )),
    );
  }
}
