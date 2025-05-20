import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

enum LoadoutListItemAction { Equip, Edit, Delete }

typedef OnLoadoutListItemAction = void Function(LoadoutListItemAction action);

const _loadoutListItemMaxWidth = 504.0;

class LoadoutSmallListItemWidget extends StatelessWidget {
  static const maxWidth = _loadoutListItemMaxWidth;
  final LoadoutItemIndex loadout;
  final DestinyClass? classFilter;
  final List<int>? bucketFilter;
  final VoidCallback? onTap;

  const LoadoutSmallListItemWidget(this.loadout, {Key? key, this.classFilter, this.bucketFilter, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: kToolbarHeight),
      margin: const EdgeInsets.all(4),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: context.theme.onSurfaceLayers.withValues(alpha: .5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(children: [
          Positioned.fill(child: buildBackground(context)),
          Container(
            padding: EdgeInsets.all(2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildTitle(context),
                buildItems(context),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget buildBackground(BuildContext context) {
    final emblemHash = loadout.emblemHash;
    if (emblemHash != null) {
      return ManifestImageWidget<DestinyInventoryItemDefinition>(
        emblemHash,
        fit: BoxFit.cover,
        urlExtractor: (def) => def.secondarySpecial,
        alignment: const Alignment(-1, 0),
      );
    }
    return Container(color: context.theme.secondarySurfaceLayers.layer2);
  }

  Widget buildTitle(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.withValues(alpha: .7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          loadout.name.toUpperCase(),
          style: context.textTheme.highlight,
        ));
  }

  Widget buildItems(BuildContext context) {
    final items = (loadout.getEquippedItems(null) + loadout.getNonEquippedItems())
        .where((element) => element.inventoryItem != null);
    return Container(
      padding: EdgeInsets.all(4),
      child: Wrap(
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: items.map((e) => buildItem(context, e)).whereType<Widget>().toList(),
      ),
    );
  }

  Widget? buildItem(BuildContext context, LoadoutItemInfo item) {
    final def = context.definition<DestinyInventoryItemDefinition>(item.itemHash);
    if (classFilter != null) {
      final classType = def?.classType;
      if (classType != classFilter && classType != DestinyClass.Unknown) return null;
    }
    if (bucketFilter != null) {
      final bucketHash = def?.inventory?.bucketTypeHash;
      final matches = bucketFilter?.contains(bucketHash) ?? false;
      if (!matches) {
        return null;
      }
    }
    return Container(
        width: 32,
        height: 32,
        margin: EdgeInsets.only(right: 2),
        child: InventoryItemIcon(
          item,
          borderSize: .5,
        ));
  }
}
