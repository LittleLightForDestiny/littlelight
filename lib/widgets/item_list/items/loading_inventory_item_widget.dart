// @dart=2.9

import 'package:flutter/material.dart';

class LoadingInventoryItemWidget extends StatelessWidget {
  const LoadingInventoryItemWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.1),
          border: Border.all(
            color: Theme.of(context).cardColor,
            width: 2,
          )),
    );
  }
}
