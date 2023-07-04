import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';

class DetailsItemCoverPersistentCollapsibleContainer extends PersistentCollapsibleContainer {
  final double pixelSize;
  DetailsItemCoverPersistentCollapsibleContainer({
    required Widget title,
    required Widget content,
    required String persistenceID,
    this.pixelSize = 1,
  }) : super(
          title: title,
          content: content,
          persistenceID: persistenceID,
        );

  @override
  Widget buildHeader(BuildContext context, bool visible) {
    return Container(
      padding: EdgeInsets.all(4 * pixelSize),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: context.theme.onSurfaceLayers,
        width: 1 * pixelSize,
      ))),
      child: Row(children: [
        Expanded(
            child: DefaultTextStyle(
          child: title,
          style: context.textTheme.caption.copyWith(fontSize: 18 * pixelSize),
        )),
        buildToggleButton(context, visible),
      ]),
    );
  }

  @override
  double get toggleButtonSize => 20 * pixelSize;

  @override
  double get headerSpacing => 8 * pixelSize;
}
