import 'package:flutter/material.dart';

/// base data to build pop up menu item
class PopupMenuData<TKey, TItem> {
  TKey id;
  String title;
  IconData? icon;
  void Function(BuildContext ctx, TItem item)? onClick;

  PopupMenuData(this.id, this.title, {this.icon, this.onClick});
}

/// helper to show the context menu on certain item (like a list view whatever)
class MenuContext<TKey, TItem> {
  List<PopupMenuData<TKey, TItem>> items;
  MenuContext(this.items);

  /// creates popupmenu entries from the [PopupMenuData].
  /// [PopupMenuEntry.onTap] is not initialized
  List<PopupMenuEntry<TKey>> toMenu() {
    return items.map((e) {
      var cld = e.icon == null
          ? [Text(e.title)]
          : [Icon(e.icon), const SizedBox(width: 10), Text(e.title)];
      var res = PopupMenuItem<TKey>(
        value: e.id,
        child: Row(children: cld),
      );
      return res;
    }).toList();
  }

  Future<void> show(BuildContext ctx, TItem kindT, Offset tapPosition) {
    final RenderBox overlay =
        Overlay.of(ctx)?.context.findRenderObject() as RenderBox;

    return showMenu<TKey>(
            context: ctx,
            items: toMenu(),
            position: RelativeRect.fromRect(
                tapPosition &
                    const Size(40, 40), // smaller rect, the touch area
                Offset.zero & overlay.size // Bigger rect, the entire screen
                ))
        .then((v) {
      if (v != null) {
        contextKindMenuClick(ctx, v, kindT, items);
      }
    });
  }

  void contextKindMenuClick(BuildContext ctx, TKey? v, TItem kindT,
      List<PopupMenuData<TKey, TItem>> items) {
    if (v == null) {
      return; // popup menu has been cancelled
    }
    var popEntry = items.firstWhere((element) => element.id == v);
    if (popEntry.onClick != null) {
      popEntry.onClick!(ctx, kindT);
    }
  }

  /// has to be called onTap to initialize [tapPosition]
  void storePosition(TapDownDetails details) {
    tapPosition = details.globalPosition;
  }

  late Offset tapPosition;
}
