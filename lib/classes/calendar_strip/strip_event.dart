part of 'strip_bloc.dart';

abstract class StripEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StripLoadEvent extends StripEvent {
  DateTime when;
  int daysBack;
  StripLoadEvent(this.when, this.daysBack);
  @override
  List<Object?> get props => [when, daysBack];
}
