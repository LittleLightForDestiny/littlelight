import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:tinycolor2/tinycolor2.dart';

typedef OnTap = void Function();

class ModIconWidget extends StatelessWidget {
  final int plugHash;
  final bool selected;
  final bool equipped;
  final bool available;
  final bool isFavorite;
  final double borderWidth;
  final bool selectable;
  final void Function()? onTap;

  ModIconWidget(
    this.plugHash, {
    this.selected = false,
    this.equipped = false,
    this.available = true,
    this.selectable = true,
    this.isFavorite = false,
    this.borderWidth = 1.5,
    this.onTap,
    Key? key,
  }) : super(
         key: key ?? Key("mod_grid_item_$plugHash"),
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.surfaceLayers.layer0,
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

  Widget buildWithDefinition(BuildContext context, DestinyInventoryItemDefinition? def) {
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

  Widget? buildEnergyTypeOverlay(BuildContext context, DestinyInventoryItemDefinition? def) {
    var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    if ([DestinyEnergyType.Any, DestinyEnergyType.Subclass, DestinyEnergyType.Ghost].contains(energyType)) return null;

    return Positioned.fill(
      child: ManifestImageWidget<DestinyStatDefinition>(
        DestinyData.getEnergyTypeCostHash(energyType),
      ),
    );
  }

  Widget? buildEnergyCostOverlay(BuildContext context, DestinyInventoryItemDefinition? def) {
    final plugCategoryIdentifier = def?.plug?.plugCategoryIdentifier;
    if (plugCategoryIdentifier?.contains("armor.masterworks") ?? false) return null;
    final energyCost = def?.plug?.energyCost?.energyCost ?? 0;
    final energyCapacity = def?.plug?.energyCapacity?.capacityValue ?? 0;
    String text = "";
    if (energyCost > 0)
      text = "$energyCost";
    else if (energyCapacity > 0)
      text = "+$energyCapacity";
    else
      return null;
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
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? buildBorder(BuildContext context) {
    final theme = context.theme;
    Color borderColor = theme.onSurfaceLayers.layer3.withValues(alpha: .5);
    if (equipped && selected) {
      borderColor = theme.primaryLayers.layer0.mix(theme.onSurfaceLayers.layer0, 30);
    } else if (selected) {
      borderColor = theme.primaryLayers.layer0;
    } else if (equipped) {
      borderColor = theme.onSurfaceLayers.layer0;
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
      ),
    );
  }

  Widget? buildFavoriteTag(BuildContext context) {
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
                bottom: 2,
                right: 2,
              ),
              child: Container(
                decoration: BoxDecoration(
                    color: context.theme.onSurfaceLayers.layer0,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.theme.errorLayers.layer0,
                      width: 1.5,
                    )),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  FontAwesomeIcons.solidHeart,
                  size: 16,
                  color: context.theme.errorLayers.layer3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? buildSeasonBadgeIcon(BuildContext context, DestinyInventoryItemDefinition? definition) {
    var badgeURL = definition?.iconWatermark;
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
    if (available) return null;
    return Positioned.fill(
      child: Container(
        color: context.theme.surfaceLayers.layer0.withValues(alpha: .5),
      ),
    );
  }

  Widget? buildInkWell(BuildContext context) {
    final onTap = this.onTap;
    if (onTap == null || !selectable) return null;
    return Positioned.fill(
      child: InkWell(
        onTap: onTap,
      ),
    );
  }
}
