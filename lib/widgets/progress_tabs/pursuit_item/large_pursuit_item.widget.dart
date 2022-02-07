// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item/pursuit_item.widget.dart';

class LargePursuitItemWidget extends PursuitItemWidget {
  LargePursuitItemWidget(
      {Key key,
      characterId,
      item,
      onTap,
      bool selectable = false,
      Widget trailing})
      : super(
            key: key,
            characterId: characterId,
            item: item,
            onTap: onTap,
            titleFontSize: 14,
            iconSize: 72,
            tagIconSize: 16,
            paddingSize: 8,
            trailing: trailing,
            selectable: selectable);

  LargePursuitItemWidgetState createState() => LargePursuitItemWidgetState();
}

class LargePursuitItemWidgetState<T extends LargePursuitItemWidget>
    extends PursuitItemWidgetState<T> {}
