import 'package:flutter/material.dart';
import 'package:little_light/shared/widgets/containers/menu_info_box.dart';

class MenuBoxTitle extends MenuInfoBox {
  MenuBoxTitle(String title, {Key? key, Widget? trailing})
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
