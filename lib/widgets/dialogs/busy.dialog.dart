import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';

class BusyDialogRoute<T> extends DialogRoute<T> {
  BusyDialogRoute(BuildContext context, {Widget? label, Future<T>? awaitFuture})
      : super(
          context: context,
          barrierDismissible: false,
          builder: (context) => awaitFuture != null
              ? BusyDialog.await(context, label: label, future: awaitFuture)
              : BusyDialog(label: label),
        );
}

class BusyDialog extends LittleLightBaseDialog {
  BusyDialog({required Widget? label})
      : super(
          bodyBuilder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LoadingAnimWidget(),
              if (label != null) Container(child: label, padding: EdgeInsets.only(top: 8)),
            ],
          ),
        );
  factory BusyDialog.await(BuildContext context, {Widget? label, required Future future}) {
    future.then((value) => Navigator.of(context).pop(value));
    return BusyDialog(label: label);
  }

  CrossAxisAlignment get crossAxisAlignment => CrossAxisAlignment.center;
}
