import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab_menu.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

const _weaponIconPresentationNodeHash = 1627803277;
const _armorIconPresentationNodeHash = 615947643;
const _inventoryIconPresentationNodeHash = 3517356538;

const iconWidth = 92.0;

class EquipmentTypeTabMenuWidget extends CustomTabMenu {
  EquipmentTypeTabMenuWidget(CustomTabController controller) : super(controller);

  @override
  double getButtonSize(BuildContext context) => iconWidth;

  Color getItemForegroundColor(BuildContext context, int index) {
    final opacity = (index - controller.animation.value).abs().clamp(0, 1).toDouble();
    final selectedColor = context.theme.onSurfaceLayers.layer0;
    final unselectedColor = context.theme.onSurfaceLayers.layer3.withOpacity(.7);
    return Color.lerp(selectedColor, unselectedColor, opacity) ?? Colors.transparent;
  }

  @override
  Widget buildButton(BuildContext context, int index) {
    return Container(padding: EdgeInsets.all(4), child: buildIcon(context, index));
  }

  Widget buildIcon(BuildContext context, int index) {
    switch (index) {
      case 0:
        return ManifestImageWidget<DestinyPresentationNodeDefinition>(
          _weaponIconPresentationNodeHash,
          color: getItemForegroundColor(context, index),
        );
      case 1:
        return ManifestImageWidget<DestinyPresentationNodeDefinition>(
          _armorIconPresentationNodeHash,
          color: getItemForegroundColor(context, index),
        );
      case 2:
        return ManifestImageWidget<DestinyPresentationNodeDefinition>(
          _inventoryIconPresentationNodeHash,
          color: getItemForegroundColor(context, index),
        );
    }
    return Container();
  }

  @override
  Widget buildSelectedBackground(BuildContext context) {
    return Container(
      color: context.theme.surfaceLayers.layer3,
    );
  }

  @override
  Widget buildSelectedIndicator(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      height: kToolbarHeight,
      child: Container(
        height: 2,
        color: Colors.white,
      ),
    );
  }
}
