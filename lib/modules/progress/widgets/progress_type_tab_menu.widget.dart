import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab_menu.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

const _milestonesQuestStepNodeHash = 4018888208;
const _pursuitsIconRecordHash = 435168078;
const _ranksIconObjectiveHash = 1674713289;

const iconWidth = 92.0;

class ProgressTypeTabMenuWidget extends CustomTabMenu {
  const ProgressTypeTabMenuWidget(CustomTabController controller) : super(controller);

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
    final mq = MediaQuery.of(context);
    return Container(
        padding: const EdgeInsets.all(8) + EdgeInsets.only(bottom: mq.viewPadding.bottom),
        child: buildIcon(context, index));
  }

  Widget buildIcon(BuildContext context, int index) {
    switch (index) {
      case 0:
        return ManifestImageWidget<DestinyInventoryItemDefinition>(
          _milestonesQuestStepNodeHash,
          color: getItemForegroundColor(context, index),
        );
      case 1:
        return ManifestImageWidget<DestinyRecordDefinition>(
          _pursuitsIconRecordHash,
          color: getItemForegroundColor(context, index),
        );
      case 2:
        return ManifestImageWidget<DestinyObjectiveDefinition>(
          _ranksIconObjectiveHash,
          color: getItemForegroundColor(context, index),
        );
    }
    return Container();
  }

  @override
  Widget buildSelectedBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          context.theme.surfaceLayers.layer2,
          context.theme.surfaceLayers.layer2.withOpacity(0),
        ],
        end: Alignment.bottomCenter,
      )),
    );
  }

  @override
  Widget buildSelectedIndicator(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Container(
        height: 2,
        color: Colors.white,
      ),
    );
  }
}
