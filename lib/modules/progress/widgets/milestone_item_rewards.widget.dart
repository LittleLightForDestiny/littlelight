import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/progress/widgets/milestone_item_info_box.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class MilestoneItemRewardsCategoryWidget extends StatelessWidget {
  final DestinyMilestoneRewardCategoryDefinition categoryDefinition;
  final List<DestinyMilestoneRewardEntry> entries;
  final VoidCallback? onTap;

  const MilestoneItemRewardsCategoryWidget({
    Key? key,
    required this.categoryDefinition,
    required this.entries,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rewardName = categoryDefinition.displayProperties?.name;
    return MilestoneItemInfoBoxWidget(
      title: Text(
        rewardName ?? "Rewards".translate(context).toUpperCase(),
        style: context.textTheme.button,
      ),
      content: Row(
        children: entries //
            .map((entry) => buildRewardEntry(context, entry))
            .whereType<Widget>()
            .toList(),
      ),
      onTap: onTap,
    );
  }

  Widget? buildRewardEntry(BuildContext context, DestinyMilestoneRewardEntry entry) {
    final entryDef = categoryDefinition.rewardEntries?["${entry.rewardEntryHash}"];
    final items = entryDef?.items;
    if (items == null || items.isEmpty) return null;
    return Row(
        children: items //
            .map((item) => buildRewardItem(context, item: item, entry: entry))
            .toList());
  }

  Widget buildRewardItem(
    BuildContext context, {
    required DestinyMilestoneRewardEntry entry,
    required DestinyItemQuantity item,
  }) {
    return Opacity(
        opacity: (entry.earned ?? false) ? 1 : .6,
        child: Container(
          width: 24,
          height: 24,
          margin: EdgeInsets.only(right: 4),
          child: Stack(clipBehavior: Clip.none, children: [
            ManifestImageWidget<DestinyInventoryItemDefinition>(item.itemHash),
            if (entry.redeemed ?? false)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.theme.upgradeLayers.layer0,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FontAwesomeIcons.check,
                    size: 8,
                  ),
                ),
              ),
          ]),
        ));
  }
}
