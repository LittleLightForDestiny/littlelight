//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.yes_no.dialog.dart';

class BusyDialogRoute<T> extends DialogRoute<T> {
  BusyDialogRoute(BuildContext context, {required Widget label, Future<T>? awaitFuture})
      : super(
          context: context,
          barrierDismissible: false,
          builder: (context) => awaitFuture != null
              ? BusyDialog.await(context, label: label, future: awaitFuture)
              : BusyDialog(label: label),
        );
}

class BusyDialog extends LittleLightYesNoDialog {
  BusyDialog({required Widget label})
      : super(
          bodyBuilder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [LoadingAnimWidget(), Container(height: 8), label],
          ),
        );
  factory BusyDialog.await(BuildContext context, {required Widget label, required Future future}) {
    future.then((value) => Navigator.of(context).pop(value));
    return BusyDialog(label: label);
  }

  CrossAxisAlignment get crossAxisAlignment => CrossAxisAlignment.center;
}
