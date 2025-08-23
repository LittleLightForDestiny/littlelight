import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:provider/provider.dart';

class DetailsItemItemSetWidget extends StatelessWidget {
  final int itemSetHash;
  DetailsItemItemSetWidget(this.itemSetHash);

  @override
  Widget build(BuildContext context) {
    final itemSetDef = context.definition<DestinyEquipableItemSetDefinition>(itemSetHash);
    if (itemSetDef == null) return Container();
    return Container(
      padding: EdgeInsets.all(4),
      child: PersistentCollapsibleContainer(
        title: ManifestText<DestinyEquipableItemSetDefinition>(itemSetHash, uppercase: true),
        persistenceID: 'item set $itemSetHash',
        content: buildContent(context, itemSetDef),
      ),
    );
  }

  Widget buildContent(BuildContext context, DestinyEquipableItemSetDefinition itemSetDef) {
    final perks = itemSetDef.setPerks;
    if (perks == null) return Container();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: perks.map((e) => buildPerk(context, e)).toList(),
    );
  }

  Widget buildPerk(BuildContext context, DestinyItemSetPerkDefinition perkSet) {
    final sandboxPerkHash = perkSet.sandboxPerkHash;
    if (sandboxPerkHash == null) return Container();
    final itemDetailsBloc = context.watch<ItemDetailsBloc>();
    final itemSetCount = itemDetailsBloc.itemSetCount;
    final requiredSetCount = perkSet.requiredSetCount ?? 99;
    final isPerkEnabled = itemSetCount != null && itemSetCount >= requiredSetCount;
    // Don't darken inactive perks when viewing in collections, vendors, etc.
    final isPerkDisabled = itemSetCount != null && !isPerkEnabled;
    return Container(
      padding: const EdgeInsets.all(8),
      child: Opacity(
        opacity: isPerkDisabled ? .7 : 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildIcon(context, perkSet, isPerkEnabled),
            Container(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeading(context, perkSet),
                  buildDescription(context, perkSet),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIcon(BuildContext context, DestinyItemSetPerkDefinition perkSet, bool isPerkEnabled) {
    final sandboxPerkHash = perkSet.sandboxPerkHash;
    if (sandboxPerkHash == null) return Container();
    final iconSize = 50.0;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(iconSize / 2),
        border: Border.all(color: context.theme.onSurfaceLayers.layer2, width: 1),
        color: isPerkEnabled ? context.theme.primaryLayers.layer1 : context.theme.surfaceLayers.layer0,
      ),
      width: iconSize,
      height: iconSize,
      padding: const EdgeInsets.all(4),
      child: ManifestImageWidget<DestinySandboxPerkDefinition>(sandboxPerkHash),
    );
  }

  Widget buildHeading(BuildContext context, DestinyItemSetPerkDefinition perkSet) {
    final sandboxPerkHash = perkSet.sandboxPerkHash;
    final requiredSetCount = perkSet.requiredSetCount;
    if (sandboxPerkHash == null || requiredSetCount == null) return Container();
    final sandboxPerkDef = context.definition<DestinySandboxPerkDefinition>(sandboxPerkHash);
    if (sandboxPerkDef == null) return Container();
    final sandboxPerkName = sandboxPerkDef.displayProperties?.name ?? "";
    final textStyle = context.theme.textTheme.subtitle;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            requiredSetCount.toString() + " " + "Piece".translate(context).toUpperCase(),
            style: textStyle,
          ),
          VerticalDivider(
            thickness: 1.5,
            width: 8,
            indent: 4,
            color: context.theme.onSurfaceLayers.layer2,
          ),
          Container(
            child: Text(
              sandboxPerkName.toUpperCase(),
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDescription(BuildContext context, DestinyItemSetPerkDefinition perkSet) {
    final sandboxPerkHash = perkSet.sandboxPerkHash;
    if (sandboxPerkHash == null) return Container();
    final sandboxPerkDef = context.definition<DestinySandboxPerkDefinition>(sandboxPerkHash);
    if (sandboxPerkDef == null) return Container();
    final sandboxPerkDescription = sandboxPerkDef.displayProperties?.description ?? "";
    return Container(
      margin: const EdgeInsets.only(top: 2),
      child: Text(
        sandboxPerkDescription,
        style: context.theme.textTheme.subtitle.copyWith(fontWeight: FontWeight.w300),
      ),
    );
  }
}
