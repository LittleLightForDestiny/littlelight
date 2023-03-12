import 'dart:math';

import 'package:flutter/material.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/page_storage_helper.dart';

class HeightKeeperKey extends StorableValue<double> {
  HeightKeeperKey(Key key, [double? value]) : super(key, value);
}

class HeightKeeperWidget extends StatelessWidget {
  final Widget child;
  const HeightKeeperWidget(this.child, {required Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = this.key;
    if (key == null) {
      return child;
    }
    final height = context.readValue(HeightKeeperKey(key))?.value;
    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(minHeight: height ?? 0),
      child: Stack(children: [
        Positioned.fill(child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight;
            if (!constraints.hasInfiniteHeight) {
              final newHeight = max(height ?? 0, maxHeight);
              context.storeValue(HeightKeeperKey(key, newHeight));
            }
            return Container();
          },
        )),
        child,
      ]),
    );
  }
}
