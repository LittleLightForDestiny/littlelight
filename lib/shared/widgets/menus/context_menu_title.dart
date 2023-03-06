import 'package:flutter/material.dart';
import 'package:little_light/shared/widgets/menus/context_menu_info_box.dart';

class ContextMenuTitle extends ContextMenuInfoBox {
  ContextMenuTitle(String title, {Key? key, Widget? trailing})
      : super(
          key: key,
          child: Row(children: [
            Expanded(
              child: Text(
                title,
              ),
            ),
            if (trailing != null) trailing,
          ]),
        );
}
