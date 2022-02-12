//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';

typedef DialogOptionSelected = Function(BuildContext context, bool value);

abstract class LittleLightYesNoDialog extends LittleLightBaseDialog {
  final DialogOptionSelected? onSelectCallback;

  LittleLightYesNoDialog(
      {Key? key, DialogWidgetBuilder? titleBuilder, DialogWidgetBuilder? bodyBuilder, this.onSelectCallback})
      : super(
          key: key,
          titleBuilder: titleBuilder,
          bodyBuilder: bodyBuilder,
        );

  @override
  Widget? buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: TranslatedTextWidget("No", uppercase: true),
          onPressed: () {
            onSelect(context, false);
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: TranslatedTextWidget("Yes", uppercase: true),
          onPressed: () async {
            onSelect(context, true);
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  void onSelect(BuildContext context, bool value) {
    onSelectCallback?.call(context, value);
  }
}
