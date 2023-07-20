import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/utils/extensions/string/replace_string_variables.dart';
import 'package:little_light/shared/widgets/modals/base_list_bottom_sheet.base.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class _RewardEntryAndItemPair {
  final DestinyMilestoneRewardEntry entry;
  final DestinyItemQuantity item;

  _RewardEntryAndItemPair({required this.entry, required this.item});
}

class MilestoneRewardsBottomSheet extends BaseListBottomSheet {
  final DestinyMilestoneRewardCategoryDefinition categoryDefinition;
  final List<_RewardEntryAndItemPair> items;
  factory MilestoneRewardsBottomSheet(
    List<DestinyMilestoneRewardEntry> entries,
    DestinyMilestoneRewardCategoryDefinition categoryDefinition,
  ) {
    final items = <_RewardEntryAndItemPair>[];
    for (final entry in entries) {
      final entryDef = categoryDefinition.rewardEntries?["${entry.rewardEntryHash}"];
      final values = entryDef?.items?.map((item) => _RewardEntryAndItemPair(entry: entry, item: item));
      if (values != null) items.addAll(values);
    }
    return MilestoneRewardsBottomSheet._(categoryDefinition, items);
  }

  MilestoneRewardsBottomSheet._(this.categoryDefinition, this.items);

  @override
  Widget? buildHeader(BuildContext context) {
    return Text(
      categoryDefinition.displayProperties?.name ?? "Rewards".translate(context),
    );
  }

  @override
  Widget? buildItemLabel(BuildContext context, int index) {
    final itemEntry = items.elementAtOrNull(index);
    if (itemEntry == null) return null;
    final itemHash = itemEntry.item.itemHash;
    bool earned = itemEntry.entry.earned ?? false;
    bool redeemed = itemEntry.entry.redeemed ?? false;
    final entryDef = categoryDefinition.rewardEntries?["${itemEntry.entry.rewardEntryHash}"];
    final entryName = entryDef?.displayProperties?.name;
    final entryDescription = entryDef?.displayProperties?.description;
    final hasDescription = entryDescription != null && entryDescription.isNotEmpty;
    return Opacity(
      opacity: (itemEntry.entry.earned ?? false) ? 1 : .6,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildRewardIcon(context, itemEntry),
            if (entryName != null && entryName.isNotEmpty)
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(entryName),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 4),
                        child: ManifestText<DestinyInventoryItemDefinition>(
                          itemHash,
                          style: context.textTheme.body,
                        ),
                      ),
                      if (redeemed)
                        Flexible(
                            child: Text(
                          "(Redeemed)".translate(context),
                          style: context.textTheme.body,
                        )),
                      if (earned && !redeemed)
                        Flexible(
                          child: Text(
                            "(Available)".translate(context),
                            style: context.textTheme.body,
                          ),
                        ),
                    ],
                  )
                ]),
              ),
          ],
        ),
        if (hasDescription)
          Container(
            margin: EdgeInsets.all(8),
            child: Text(
              entryDescription.replaceBungieVariables(context),
              style: context.textTheme.body,
            ),
          )
      ]),
    );
  }

  Widget buildRewardIcon(
    BuildContext context,
    _RewardEntryAndItemPair itemEntry,
  ) {
    final item = itemEntry.item;
    final entry = itemEntry.entry;
    return Container(
      width: 24,
      height: 24,
      margin: EdgeInsets.only(right: 8),
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
    );
  }

  @override
  int? get itemCount => items.length;
}
