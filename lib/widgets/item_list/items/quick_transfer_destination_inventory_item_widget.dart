// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

class QuickTransferDestinationItemWidget extends StatelessWidget {
  QuickTransferDestinationItemWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.1),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondaryContainer,
              width: 2,
            )),
        child: Center(
          child: Icon(Icons.add_circle_outline, color: LittleLightTheme.of(context).surfaceLayers.layer3),
        ));
  }
}
