// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item/pursuit_item.widget.dart';

class LargePursuitItemWidget extends PursuitItemWidget {
  const LargePursuitItemWidget({
    Key key,
    ItemWithOwner item,
    onTap,
    bool selectable = false,
    Widget trailing,
  }) : super(
            key: key,
            item: item,
            onTap: onTap,
            titleFontSize: 14,
            iconSize: 72,
            tagIconSize: 16,
            paddingSize: 8,
            trailing: trailing,
            selectable: selectable);

  @override
  LargePursuitItemWidgetState createState() => LargePursuitItemWidgetState();
}

class LargePursuitItemWidgetState<T extends LargePursuitItemWidget> extends PursuitItemWidgetState<T> {}
