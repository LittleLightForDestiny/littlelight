// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

typedef void AsEquippedChanged(bool equipped);

class AsEquippedSwitchWidget extends StatefulWidget {
  final AsEquippedChanged onChanged;

  const AsEquippedSwitchWidget({Key key, this.onChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AsEquippedSwitchWidgetState();
  }
}

class AsEquippedSwitchWidgetState extends State<AsEquippedSwitchWidget> {
  bool asEquipped = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: <Widget>[
            Expanded(child: TranslatedTextWidget("As Equipped")),
            Switch(
              value: asEquipped,
              onChanged: (bool value) {
                asEquipped = value;
                setState(() {});
                if (widget.onChanged != null) {
                  widget.onChanged(asEquipped);
                }
              },
            ),
          ],
        ));
  }
}
