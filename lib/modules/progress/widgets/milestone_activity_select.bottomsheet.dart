import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/modals/base_item_selection_bottom_sheet.base.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

class MilestoneActivitySelectBottomSheet extends BaseItemSelectionBottomSheet<int> {
  final List<int> activityHashes;
  MilestoneActivitySelectBottomSheet(this.activityHashes);
  @override
  Widget? buildHeader(BuildContext context) {
    return Text("Select an activity".translate(context).toUpperCase());
  }

  @override
  Widget? buildItemLabel(BuildContext context, int index) {
    final hash = activityHashes.elementAtOrNull(index);
    if (hash == null) return null;
    return DefinitionProviderWidget<DestinyActivityDefinition>(
      hash,
      (def) => Row(
        children: [
          Expanded(child: Text(def?.displayProperties?.name ?? "")),
          Container(
              child: Icon(
            LittleLightIcons.power,
            size: 8,
            color: context.theme.achievementLayers,
          )),
          Text(
            "${def?.activityLightLevel}",
            style: context.textTheme.button.copyWith(
              color: context.theme.achievementLayers,
            ),
          ),
        ],
      ),
    );
  }

  @override
  int? indexToValue(int index) {
    return activityHashes[index];
  }

  @override
  int? get itemCount => activityHashes.length;
}
