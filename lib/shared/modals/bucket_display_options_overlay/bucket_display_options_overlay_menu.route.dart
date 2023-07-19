import 'package:flutter/material.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/shared/modals/bucket_display_options_overlay/bucket_display_options_overlay_menu.view.dart';

class BucketDisplayOptionsOverlayMenuRoute extends RawDialogRoute<BucketDisplayType> {
  BucketDisplayOptionsOverlayMenuRoute({
    bool canEquip = false,
    required List<BucketDisplayType> availableOptions,
    required GlobalKey buttonKey,
    required String identifier,
    required BucketDisplayType defaultValue,
  }) : super(
          transitionDuration: Duration(milliseconds: 300),
          barrierColor: Colors.transparent,
          transitionBuilder: (context, animation, secondaryAnimation, child) => child,
          pageBuilder: (context, animation, secondaryAnimation) => BucketDisplayOptionsOverlayMenuView(
            buttonKey: buttonKey,
            identifier: identifier,
            defaultValue: defaultValue,
            canEquip: canEquip,
            availableOptions: availableOptions,
            animation: animation,
          ),
        );
}
