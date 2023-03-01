import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

typedef OnTap = void Function();

class ModGridItem extends StatelessWidget with ItemNotesConsumer {
  final int plugHash;
  final bool selected;
  final bool equipped;
  final bool canEquip;
  final void Function()? onTap;

  ModGridItem(
    this.plugHash, {
    this.selected = false,
    this.equipped = false,
    this.canEquip = true,
    this.onTap,
    Key? key,
  }) : super(
          key: key ?? Key("mod_grid_item_$plugHash"),
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LittleLightTheme.of(context).surfaceLayers.layer0,
      key: Key("plug_$plugHash"),
      child: AspectRatio(
        aspectRatio: 1,
        child: DefinitionProviderWidget<DestinyInventoryItemDefinition>(
          plugHash,
          (def) => buildWithDefinition(context, def),
        ),
      ),
    );
  }

  Widget buildWithDefinition(
      BuildContext context, DestinyInventoryItemDefinition def) {
    return Stack(
      children: [
        ManifestImageWidget<DestinyInventoryItemDefinition>(plugHash),
        buildEnergyTypeOverlay(context, def),
        buildEnergyCostOverlay(context, def),
        buildSeasonBadgeIcon(context, def),
        buildFavoriteTag(context),
        buildBorder(context),
        buildDisabledOverlay(context),
        buildInkWell(context),
      ].whereType<Widget>().toList(),
    );
  }

  Widget? buildEnergyTypeOverlay(
      BuildContext context, DestinyInventoryItemDefinition def) {
    var energyType = def.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    if ([DestinyEnergyType.Any, DestinyEnergyType.Subclass]
        .contains(energyType)) return null;

    return Positioned.fill(
      child: ManifestImageWidget<DestinyStatDefinition>(
        DestinyData.getEnergyTypeCostHash(energyType),
      ),
    );
  }

  Widget? buildEnergyCostOverlay(
      BuildContext context, DestinyInventoryItemDefinition def) {
    var energyCost = def.plug?.energyCost?.energyCost ?? 0;
    if (energyCost == 0) return null;
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Transform.scale(
            alignment: Alignment.topRight,
            scale: constraints.maxWidth / 92,
            child: Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(
                top: 8,
                right: 12,
              ),
              child: Text(
                "$energyCost",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? buildBorder(BuildContext context) {
    final theme = LittleLightTheme.of(context);
    final borderColor =
        equipped ? theme.primaryLayers.layer0 : theme.onSurfaceLayers.layer0;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: borderColor.withOpacity(selected ? 1 : .5), width: 2),
      ),
    );
  }

  Widget? buildFavoriteTag(BuildContext context) {
    final isFavorite =
        itemNotes.getNotesForItem(plugHash, null)?.tags?.contains("favorite") ??
            false;
    if (!isFavorite) return null;
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Transform.scale(
            alignment: Alignment.bottomRight,
            scale: constraints.maxWidth / 92,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.only(
                bottom: 4,
                right: 4,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: LittleLightTheme.of(context).errorLayers.layer0,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  FontAwesomeIcons.solidHeart,
                  size: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? buildSeasonBadgeIcon(
      BuildContext context, DestinyInventoryItemDefinition definition) {
    var badgeURL = definition.iconWatermark;
    if (badgeURL == null || badgeURL.isEmpty) return null;
    return Positioned.fill(
      child: Container(
          padding: const EdgeInsets.all(2),
          child: QueuedNetworkImage.fromBungie(
            badgeURL,
            fit: BoxFit.fill,
          )),
    );
  }

  Widget? buildDisabledOverlay(BuildContext context) {
    if (canEquip) return null;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(.5),
      ),
    );
  }

  Widget? buildInkWell(BuildContext context) {
    final onTap = this.onTap;
    if (onTap == null) return null;
    return Positioned.fill(
      child: InkWell(
        onTap: onTap,
      ),
    );
  }
}
