part of 'list_bloc.dart';

enum ItemListStatus { initial, loading, success, failure }

extension ItemListStatusX on ItemListStatus {
  bool get isLoadingOrSuccess => [
        ItemListStatus.loading,
        ItemListStatus.success,
      ].contains(this);
}

class ListState extends Equatable {
  ListState(this.status, this.data);
  ItemListStatus status;

  @override
  List<Object?> get props => [status];

  List<WorkKindToday> data;

  ListState copyWith(
      {ItemListStatus Function()? status,
      List<WorkKindToday> Function()? data}) {
    return ListState(
      status != null ? status() : this.status,
      data != null ? data() : this.data,
    );
  }
}
