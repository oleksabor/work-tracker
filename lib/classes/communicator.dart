import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';

class Communicator {
  /// The name associated with the UI isolate's [SendPort].
  static const String isolateName = 'isolate';

  /// A port used to communicate frodm a background isolate to the UI isolate.
  final ReceivePort port = ReceivePort();

  void init(void Function(dynamic) onData) {
    // Register the UI isolate's SendPort to allow for communication from the
    // background isolate.
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      isolateName,
    );

    port.listen(onData);
  }

  static SendPort? uiSendPort;

  static void send(String data) {
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(data);
    if (uiSendPort == null && kDebugMode) {
      print("Communicator no uiSendPort instance");
    }
  }

  void close() {
    IsolateNameServer.removePortNameMapping(isolateName);
  }
}
