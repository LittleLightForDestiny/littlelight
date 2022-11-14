import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/shared/widgets/headers/bucket_header_list_item.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/selectable_item_wrapper.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';

class CharacterBucketContent {
  final int bucketHash;
  final DestinyItemInfo? equipped;
  final List<DestinyItemInfo> unequipped;

  CharacterBucketContent(
    this.bucketHash, {
    required this.equipped,
    required this.unequipped,
  });
}

class CharacterTabContentWidget extends StatelessWidget {
  final DestinyCharacterInfo character;
  final List<CharacterBucketContent> buckets;

  const CharacterTabContentWidget(
    this.character, {
    Key? key,
    required this.buckets,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        key: Key("character_tab_${character.characterId}"),
        builder: (context, constraints) => MultiSectionScrollView(
              buckets //
                  .map<List<SliverSection>>((e) => buildBucketSections(context, e, constraints)) //
                  .fold<List<SliverSection>>([], (list, element) => list + element).toList(),
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              padding: EdgeInsets.all(8).copyWith(top: 0),
            ));
  }

  List<SliverSection> buildBucketSections(
    BuildContext context,
    CharacterBucketContent bucketContent,
    BoxConstraints constraints,
  ) {
    final equipped = bucketContent.equipped;
    final unequipped = bucketContent.unequipped;
    final bucketHash = bucketContent.bucketHash;
    return [
      SliverSection.fixedHeight(
        itemCount: 1,
        itemHeight: 48,
        itemBuilder: (_, __) => BucketHeaderListItemWidget(bucketHash),
      ),
      if (equipped != null)
        SliverSection.fixedHeight(
          itemHeight: 96,
          itemCount: 1,
          itemBuilder: (_, __) => buildItem(equipped, InventoryItemWidgetDensity.High),
        ),
      if (unequipped.isNotEmpty)
        SliverSection.fixedHeight(
          itemHeight: 96,
          itemsPerRow: InventoryItemWidgetDensity.High.getIdealCount(constraints.maxWidth),
          itemCount: unequipped.length,
          itemBuilder: (_, index) => buildItem(unequipped[index], InventoryItemWidgetDensity.High),
        ),
      if (unequipped.isNotEmpty)
        SliverSection.fixedHeight(
          itemHeight: 72,
          itemsPerRow: InventoryItemWidgetDensity.Medium.getIdealCount(constraints.maxWidth),
          itemCount: unequipped.length,
          itemBuilder: (_, index) => buildItem(unequipped[index], InventoryItemWidgetDensity.Medium),
        ),
      if (unequipped.isNotEmpty)
        SliverSection.aspectRatio(
          itemAspectRatio: 1,
          itemsPerRow: InventoryItemWidgetDensity.Low.getIdealCount(constraints.maxWidth),
          itemCount: unequipped.length,
          itemBuilder: (_, index) => buildItem(unequipped[index], InventoryItemWidgetDensity.Low),
        )
    ];
  }

  Widget buildItem(DestinyItemInfo item, InventoryItemWidgetDensity density) {
    return SelectableItemWrapper(
      InventoryItemWidget(
        item,
        density: density,
      ),
      item: item,
      density: density,
    );
  }
}
