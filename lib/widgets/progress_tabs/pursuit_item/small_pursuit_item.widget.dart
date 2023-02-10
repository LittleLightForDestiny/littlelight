// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item/pursuit_item.widget.dart';

class SmallPursuitItemWidget extends PursuitItemWidget {
  const SmallPursuitItemWidget({
    Key key,
    ItemWithOwner item,
    onTap,
    bool selectable = false,
  }) : super(
          key: key,
          item: item,
          onTap: onTap,
          selectable: selectable,
        );

  @override
  SmallPursuitItemWidgetState createState() => SmallPursuitItemWidgetState();
}

class SmallPursuitItemWidgetState<T extends SmallPursuitItemWidget> extends PursuitItemWidgetState<T> {
  @override
  Widget build(BuildContext context) {
    if (definition == null) {
      return Container(height: 200, color: Theme.of(context).colorScheme.secondaryContainer);
    }
    return Stack(children: [
      Positioned.fill(child: buildIcon(context)),
      selected
          ? Positioned.fill(
              child: Container(
              foregroundDecoration: BoxDecoration(border: Border.all(color: Colors.lightBlue.shade400, width: 2)),
            ))
          : Container(),
      Positioned.fill(child: buildTapTarget(context))
    ]);
  }
}
