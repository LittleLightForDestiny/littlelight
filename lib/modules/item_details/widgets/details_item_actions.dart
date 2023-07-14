import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

class DetailsItemActionsWidget extends StatelessWidget {
  final VoidCallback? onAddToLoadout;
  final VoidCallback? onViewInCollections;

  DetailsItemActionsWidget({this.onAddToLoadout, this.onViewInCollections});

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(8).copyWith(top: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: context.theme.surfaceLayers.layer1,
      ),
      child: Row(
        children: <Widget>[
          if (onAddToLoadout != null)
            Expanded(
              child: ElevatedButton(
                child: Text(
                  "Add to Loadout".translate(context),
                  softWrap: false,
                  style: context.textTheme.button,
                ),
                onPressed: onAddToLoadout,
              ),
            ),
          if (onAddToLoadout != null && onViewInCollections != null) SizedBox(width: 8),
          if (onViewInCollections != null)
            Expanded(
              child: ElevatedButton(
                child: Text(
                  "View in Collections".translate(context),
                  softWrap: false,
                  style: context.textTheme.button,
                ),
                onPressed: onViewInCollections,
              ),
            ),
        ],
      ),
    );
  }
}
