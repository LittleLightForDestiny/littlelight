import 'package:flutter/material.dart';

class LoadingInventoryItemWidget extends StatelessWidget {
  LoadingInventoryItemWidget();
  

  @override
  Widget build(BuildContext context) {
      return Container(
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.1),
          border: Border.all(
            color: Theme.of(context).cardColor,
            width: 2,
            )
        ),
      );
    }
}
