part of 'strip_bloc.dart';

class StripState extends ListStateBase<CalendarData> {
  StripState(super.status, super.data);

  StripState copyWith({
    ItemListStatus Function()? status,
    List<CalendarData> Function()? data,
  }) {
    return StripState(
      status != null ? status() : this.status,
      data != null ? data() : this.data,
    );
  }
}
