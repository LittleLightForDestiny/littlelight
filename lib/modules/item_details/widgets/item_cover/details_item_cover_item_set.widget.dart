import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/item_details/widgets/item_cover/details_item_cover_persistent_collapsible_container.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_item_set.widget.dart';

class DetailsItemCoverItemSetWidget extends DetailsItemItemSetWidget {
  final int itemSetHash;
  final double pixelSize;
  DetailsItemCoverItemSetWidget(this.itemSetHash, {this.pixelSize = 1}) : super(itemSetHash);

  @override
  Widget build(BuildContext context) {
    final itemSetDef = context.definition<DestinyEquipableItemSetDefinition>(itemSetHash);
    if (itemSetDef == null) return Container();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10 * pixelSize),
      child: DetailsItemCoverPersistentCollapsibleContainer(
        title: ManifestText<DestinyEquipableItemSetDefinition>(itemSetHash, uppercase: true),
        persistenceID: 'item cover set $itemSetHash',
        content: buildContent(context, itemSetDef),
        pixelSize: pixelSize,
      ),
    );
  }
}