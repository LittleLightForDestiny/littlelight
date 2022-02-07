// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item/pursuit_item.widget.dart';

class SmallPursuitItemWidget extends PursuitItemWidget {
  SmallPursuitItemWidget(
      {Key key, characterId, item, onTap, bool selectable = false})
      : super(
            key: key,
            characterId: characterId,
            item: item,
            onTap: onTap,
            selectable: selectable);

  SmallPursuitItemWidgetState createState() => SmallPursuitItemWidgetState();
}

class SmallPursuitItemWidgetState<T extends SmallPursuitItemWidget>
    extends PursuitItemWidgetState<T> {
  @override
  Widget build(BuildContext context) {
    if (definition == null) {
      return Container(height: 200, color: Theme.of(context).colorScheme.secondaryVariant);
    }
    return Stack(children: [
      Positioned.fill(child: buildIcon(context)),
      selected
          ? Positioned.fill(
              child: Container(
              foregroundDecoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.lightBlue.shade400, width: 2)),
            ))
          : Container(),
      Positioned.fill(child: buildTapTarget(context))
    ]);
  }
}
