import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'work_kind.dart';

class WkNotifier extends ValueNotifier<List<WorkKind>> {
  WkNotifier(List<WorkKind> value) : super(value);
}
