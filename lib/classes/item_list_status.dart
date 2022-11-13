enum ItemListStatus { initial, loading, success, failure }

extension ItemListStatusX on ItemListStatus {
  bool get isLoadingOrSuccess => [
        ItemListStatus.loading,
        ItemListStatus.success,
      ].contains(this);
}
