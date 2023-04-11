import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';

typedef OnLockChange = void Function(bool locked);

class DetailsLockStatusWidget extends StatelessWidget {
  final bool locked;
  final bool busy;
  final OnLockChange? onChange;
  DetailsLockStatusWidget(this.locked, {this.busy = false, this.onChange});

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: MenuBox(
        child: Row(
          children: <Widget>[
            Icon(locked ? FontAwesomeIcons.lock : FontAwesomeIcons.unlock, size: 14),
            Container(
              width: 4,
            ),
            Expanded(
              child: DefaultLoadingShimmer(
                child: Text(
                  infoText(context).toUpperCase(),
                  style: context.textTheme.body,
                ),
                enabled: busy,
              ),
            ),
            ElevatedButton(
              child: DefaultLoadingShimmer(
                child: Text(
                  buttonText(context).toUpperCase(),
                  style: context.textTheme.button,
                ),
                enabled: busy,
              ),
              onPressed: busy
                  ? null
                  : () {
                      onChange?.call(!locked);
                    },
            )
          ],
        ),
      ),
    );
  }

  String infoText(BuildContext context) {
    if (locked && busy) return "Unlocking Item".translate(context);
    if (locked) return "Item Locked".translate(context);
    if (busy) return "Locking Item".translate(context);
    return "Item Unlocked".translate(context);
  }

  String buttonText(BuildContext context) {
    if (locked && busy) return "Unlocking".translate(context);
    if (locked) return "Unlock".translate(context);
    if (busy) return "Locking".translate(context);
    return "Lock".translate(context);
  }
}
