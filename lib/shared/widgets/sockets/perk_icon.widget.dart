import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

const _maxPerkIconSize = 64.0;

class PerkIconWidget extends StatelessWidget {
  static const maxIconSize = _maxPerkIconSize;
  final int plugItemHash;
  final int itemHash;
  final bool equipped;
  final bool selected;
  final VoidCallback? onTap;

  PerkIconWidget({
    required int this.plugItemHash,
    required int this.itemHash,
    this.equipped = false,
    this.selected = false,
    this.onTap,
  }) : super();

  Color perkColor(BuildContext context) => context.theme.primaryLayers.layer1;

  Color baseBorderColor(BuildContext context) => context.theme.onSurfaceLayers.layer1;

  @override
  Widget build(BuildContext context) {
    final itemDef = context.definition<DestinyInventoryItemDefinition>(itemHash);
    final plugDef = context.definition<DestinyInventoryItemDefinition>(plugItemHash);
    final intrinsic = plugDef?.plug?.plugCategoryIdentifier == "intrinsics";
    final exotic = itemDef?.inventory?.tierType == TierType.Exotic;
    Color bgColor = Colors.transparent;
    Color borderColor = baseBorderColor(context).withOpacity(.5);
    final isRound = !intrinsic || exotic;
    if (equipped && !intrinsic) {
      bgColor = perkColor(context).withOpacity(.5);
    }
    if (selected && !intrinsic) {
      bgColor = perkColor(context);
      borderColor = baseBorderColor(context);
    }

    if (intrinsic && !selected) {
      borderColor = Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.all(0),
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _maxPerkIconSize;
            final radius = BorderRadius.circular(isRound ? constraints.maxWidth / 2 : 8 * scale);
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    color: bgColor,
                    border: Border.all(color: borderColor, width: 1.5 * scale),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(intrinsic ? 0 : 4 * scale),
                    child: ManifestImageWidget<DestinyInventoryItemDefinition>(plugItemHash)),
                InkWell(
                  customBorder: isRound ? CircleBorder() : RoundedRectangleBorder(borderRadius: radius),
                  onTap: onTap,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
