part of 'main_items_page.dart';

extension WorkItemsContext on _MainItemsPageState {
  Future<void> addKind(WorkKindToday item, BuildContext context) async {
    var res = await _doRoute(item, context);
    if (res != null) {
      _model.updateKind(item.kind);
      onResumed();
    }
  }

  Future<dynamic> _doRoute(WorkKindToday item, BuildContext context) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => WorkKindView(WorkKind().assignFrom(item.kind))),
    );
    if (res != null) {
      item.kind.assignFrom(res);
    }
    return res;
  }

  Future<void> editKind(BuildContext context, WorkKindToday item) async {
    var res = await _doRoute(item, context);
    if (res != null) {
      await _model.updateKind(item.kind);
      onResumed();
    }
  }

  void deleteKind(BuildContext context, WorkKindToday item) async {
    await _model.removeKind(item.kind);
    onResumed();
  }

  PopupMenuButton<String> getMainContext(Map<String, String> menu) {
    return PopupMenuButton<String>(
        onSelected: handleClick,
        itemBuilder: (BuildContext context) {
          return menu.entries.map((e) {
            return PopupMenuItem<String>(
              value: e.key,
              child: Text(e.value),
            );
          }).toList();
        });
  }

  void handleClick(String tag) async {
    if (kDebugMode) {
      logger.fine('menu $tag');
    }
    switch (tag) {
      case _MainItemsPageState.tagDebug:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => DebugPage.m(model: _model)),
        );
        break;
      case _MainItemsPageState.tagChart:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => ChartItemsView(_model)),
        );
        break;
      case _MainItemsPageState.tagSettings:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => const ConfigPage()),
        );
        break;
      case _MainItemsPageState.tagAddKind:
        await addKind(WorkKindToday(WorkKind()), context);
        break;
    }
  }
}
