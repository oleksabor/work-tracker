part of 'main_items_page.dart';

extension WorkItemsContext on _MainItemsPageState {
  static Future<void> _doRoute(WorkKindToday item, BuildContext context) async {
    await Navigator.of(context).push(WorkKindView.route(item.kind));

    // var res = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (ctx) => WorkKindView(WorkKind().assignFrom(item.kind))),
    // );
    // if (res != null) {
    //   item.kind.assignFrom(res);
    // }
    // return res;
  }

  Future<void> editKind(BuildContext context, WorkKindToday item) async {
    var res = await _doRoute(item, context);
    // if (res != null) {
    //   await _model.updateKind(item.kind);
    //   onResumed();
    // }
  }

  Future<void> addKind(BuildContext context) async {
    var res = await _doRoute(WorkKindToday(WorkKind()), context);
    // if (res != null) {
    //   await _model.updateKind(item.kind);
    //   onResumed();
    // }
  }

  // https://api.flutter.dev/flutter/material/AlertDialog-class.html
  static Future<T?> showConfirmationDialog<T>(
      T okValue, String title, String description, BuildContext context) async {
    var t = AppLocalizations.of(context)!;
    return await showDialog<T>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              content: Text(description),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text(t.cancelCap),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, okValue),
                  child: Text(t.okCap),
                ),
              ],
            ));
  }

  PopupMenuButton<String> getMainContext(
      Map<String, String> menu, BuildContext context) {
    var bloc = context.read<ListBloc>();
    return PopupMenuButton<String>(
        onSelected: (t) => handleClick(t, context),
        itemBuilder: (BuildContext context) {
          return menu.entries.map((e) {
            return PopupMenuItem<String>(
              value: e.key,
              child: Text(e.value),
            );
          }).toList();
        });
  }

  void handleClick(String tag, BuildContext ctx) async {
    if (kDebugMode) {
      logger.fine('menu $tag');
    }
    switch (tag) {
      case _MainItemsPageState.tagDebug:
        var bloc = ctx.read<ListBloc>();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => DebugPage()),
        );
        bloc.add(LoadListEvent());
        // setState(() => loadWork());
        break;
      case _MainItemsPageState.tagChart:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => ChartItemsView()),
        );
        break;
      case _MainItemsPageState.tagSettings:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => const ConfigPage()),
        );
        break;
      case _MainItemsPageState.tagAddKind:
        await addKind(context);
        break;
    }
  }
}
