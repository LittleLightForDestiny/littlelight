import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/headers/bucket_header/item_section_header.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

const _nonEquippableDisplayOptions = [
  BucketDisplayType.Hidden,
  BucketDisplayType.Large,
  BucketDisplayType.Medium,
  BucketDisplayType.Small,
];

const _equippableDisplayOptions = [
  BucketDisplayType.OnlyEquipped,
  ..._nonEquippableDisplayOptions,
];

class BucketHeaderListItemWidget extends StatelessWidget {
  final int bucketHash;
  final int itemCount;
  final bool isVault;
  final bool canEquip;
  final BucketDisplayType defaultType;
  final GlobalKey menuGlobalKey;

  const BucketHeaderListItemWidget(
    this.bucketHash, {
    this.itemCount = 0,
    this.isVault = false,
    this.canEquip = false,
    this.defaultType = BucketDisplayType.Medium,
    required this.menuGlobalKey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final def = context.definition<DestinyInventoryBucketDefinition>(bucketHash);
    final id = isVault ? 'vault $bucketHash' : '$bucketHash';
    return ItemSectionHeaderWidget(
      globalKey: menuGlobalKey,
      sectionIdentifier: id,
      availableOptions: canEquip ? _equippableDisplayOptions : _nonEquippableDisplayOptions,
      defaultType: this.defaultType,
      title: buildLabel(context, def),
      trailing: buildCount(context, def),
    );
  }

  Widget buildLabel(BuildContext context, DestinyInventoryBucketDefinition? definition) {
    return Text(
      definition?.displayProperties?.name?.toUpperCase() ?? "",
      softWrap: false,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget buildCount(BuildContext context, DestinyInventoryBucketDefinition? definition) {
    int bucketSize = definition?.itemCount ?? 9;
    if (isVault) {
      return ManifestText<DestinyInventoryBucketDefinition>(
        InventoryBucket.general,
        textExtractor: (def) {
          return "$itemCount/${def.itemCount}";
        },
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      );
    }
    return Text(
      "$itemCount/$bucketSize",
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
