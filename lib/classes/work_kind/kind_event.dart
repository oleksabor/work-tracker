import 'package:equatable/equatable.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_kind_today.dart';

abstract class KindEvent extends Equatable {
  const KindEvent();

  @override
  List<Object> get props => [];
}

class KindAdjusted extends KindEvent {}

class KindAdded extends KindAdjusted {}

class KindUpdated extends KindAdjusted {}

class KindTitleChanged extends KindEvent {
  final String title;
  KindTitleChanged(this.title);

  @override
  List<Object> get props => [title];
}
