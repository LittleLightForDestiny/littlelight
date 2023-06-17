import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class ObjectiveTrackingReorderingItemWidget extends StatelessWidget {
  final int index;
  final TrackedObjective objective;
  final DestinyItemInfo? item;

  ObjectiveTrackingReorderingItemWidget(this.index, this.objective, {this.item});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: backgroundColor(context),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.all(4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildHandle(context),
            buildIcon(context),
            Container(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTitle(context),
                Container(height: 2),
                buildSubtitle(context),
              ],
            ),
          ],
        ),
      );

  Color? backgroundColor(BuildContext context) {
    switch (this.objective.type) {
      case TrackedObjectiveType.Triumph:
        return context.theme.surfaceLayers.layer1;
      case TrackedObjectiveType.Item:
      case TrackedObjectiveType.Plug:
      case TrackedObjectiveType.Questline:
        final definition = context.definition<DestinyInventoryItemDefinition>(objective.hash);
        return definition?.inventory?.tierType?.getColorLayer(context);
    }
  }

  Color? foregroundColor(BuildContext context) {
    switch (this.objective.type) {
      case TrackedObjectiveType.Triumph:
        return context.theme.onSurfaceLayers;
      case TrackedObjectiveType.Item:
      case TrackedObjectiveType.Plug:
      case TrackedObjectiveType.Questline:
        final definition = context.definition<DestinyInventoryItemDefinition>(objective.hash);
        return definition?.inventory?.tierType?.getTextColor(context);
    }
  }

  Widget buildHandle(BuildContext context) => ReorderableDragStartListener(
      index: index,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: Colors.transparent,
          child: Icon(
            Icons.menu,
            color: foregroundColor(context),
          ),
        ),
      ));

  Widget buildIcon(BuildContext context) {
    switch (this.objective.type) {
      case TrackedObjectiveType.Triumph:
        return ManifestImageWidget<DestinyRecordDefinition>(objective.hash);
      case TrackedObjectiveType.Item:
      case TrackedObjectiveType.Plug:
      case TrackedObjectiveType.Questline:
        final item = this.item;
        if (item != null) return InventoryItemIcon(item);
        return Container();
    }
  }

  Widget buildTitle(BuildContext context) {
    final textStyle = context.textTheme.itemNameHighDensity.copyWith(
      color: foregroundColor(context),
    );
    switch (this.objective.type) {
      case TrackedObjectiveType.Triumph:
        return ManifestText<DestinyRecordDefinition>(
          objective.hash,
          style: textStyle,
        );
      case TrackedObjectiveType.Item:
        return ManifestText<DestinyInventoryItemDefinition>(
          objective.hash,
          style: textStyle,
        );
      case TrackedObjectiveType.Plug:
        return ManifestText<DestinyInventoryItemDefinition>(
          objective.hash,
          style: textStyle,
        );
      case TrackedObjectiveType.Questline:
        return ManifestText<DestinyInventoryItemDefinition>(
          objective.hash,
          style: textStyle,
        );
    }
  }

  Widget buildSubtitle(BuildContext context) {
    final textStyle = context.textTheme.caption.copyWith(
      color: foregroundColor(context),
    );
    switch (this.objective.type) {
      case TrackedObjectiveType.Triumph:
        return Text(
          "Triumph".translate(context),
          style: textStyle,
        );
      case TrackedObjectiveType.Item:
        return ManifestText<DestinyInventoryItemDefinition>(
          objective.hash,
          textExtractor: (def) => def.itemTypeDisplayName,
          style: textStyle,
        );
      case TrackedObjectiveType.Plug:
        return ManifestText<DestinyInventoryItemDefinition>(
          objective.hash,
          textExtractor: (def) => def.itemTypeDisplayName,
          style: textStyle,
        );
      case TrackedObjectiveType.Questline:
        return ManifestText<DestinyInventoryItemDefinition>(
          objective.hash,
          textExtractor: (def) => def.itemTypeDisplayName,
          style: textStyle,
        );
    }
  }
}
