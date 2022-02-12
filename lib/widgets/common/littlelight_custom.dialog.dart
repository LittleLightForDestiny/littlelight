// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class LittleLightCustomDialog extends Dialog {
  LittleLightCustomDialog(Widget content,
      {Widget title,
      Widget footer,
      double maxWidth = 600,
      double maxHeight = 500})
      : super(
            insetPadding: EdgeInsets.all(8),
            child: Container(
              constraints:
                  BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
              padding: EdgeInsets.all(8).copyWith(bottom: 4),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                title != null ? HeaderWidget(child: title) : Container(),
                Flexible(child: content),
                Container(
                  height: 8,
                ),
                footer != null ? footer : Container()
              ]),
            ));

  factory LittleLightCustomDialog.withHorizontalButtons(Widget content,
      {@required List<Widget> buttons, Widget title, double maxWidth = 600}) {
    List<Widget> footerWidgets = [];
    for (var i = 0; i < buttons.length; i++) {
      footerWidgets.add(Expanded(
        child: buttons[i],
      ));
      if (i < buttons.length - 1)
        footerWidgets.add(Container(
          width: 4,
        ));
    }
    return LittleLightCustomDialog(content,
        title: title,
        maxWidth: maxWidth,
        footer: Row(
          children: footerWidgets,
        ));
  }

  factory LittleLightCustomDialog.withSaveCancelButtons(Widget content,
      {Widget title,
      @required Function onSave,
      @required Function onCancel,
      double maxWidth = 600}) {
    return LittleLightCustomDialog.withHorizontalButtons(content,
        maxWidth: maxWidth,
        title: title,
        buttons: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity.comfortable,
              ),
              child: TranslatedTextWidget("Cancel",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                onCancel();
              }),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity.comfortable,
              ),
              child: TranslatedTextWidget("Save",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                onSave();
              })
        ]);
  }

  factory LittleLightCustomDialog.withYesNoButtons(Widget content,
      {Widget title,
      double maxWidth = 600,
      @required Function yesPressed,
      @required Function noPressed}) {
    return LittleLightCustomDialog.withHorizontalButtons(content,
        title: title,
        maxWidth: maxWidth,
        buttons: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity.comfortable,
              ),
              child: TranslatedTextWidget("No",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                noPressed();
              }),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity.comfortable,
              ),
              child: TranslatedTextWidget("Yes",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                yesPressed();
              })
        ]);
  }
}
