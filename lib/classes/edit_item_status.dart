enum EditItemStatus { initial, loading, saving, success, failure }

extension EditItemStatusX on EditItemStatus {
  bool get isLoadingOrSuccess => [
        EditItemStatus.loading,
        EditItemStatus.saving,
        EditItemStatus.success,
      ].contains(this);
}
