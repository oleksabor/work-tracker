import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DirEntry {
  final String title;
  final String? path;

  DirEntry(this.title, this.path);
}

class DirData extends Iterable<DirEntry> {
  final String appDocuments;
  String? appLibrary;
  String? extStorage;

  DirData(
      {required this.appDocuments,
      required this.extStorage,
      required this.appLibrary});

  static Future<Directory?> safeDir(Function fd) async {
    try {
      return await fd();
    } catch (e) {
      return null;
    }
  }

  static Future<DirData> loadDirectories() async {
    var docDir = await getApplicationDocumentsDirectory();
    Directory? libDir = await safeDir(getLibraryDirectory);

    var es = await safeDir(getExternalStorageDirectory);
    return DirData(
        appDocuments: docDir.path,
        extStorage: es?.path,
        appLibrary: libDir?.path);
  }

  @override
  Iterator<DirEntry> get iterator => [
        DirEntry("documents", appDocuments),
        DirEntry("library", appLibrary),
        DirEntry("extStorage", extStorage)
      ].iterator;
}
