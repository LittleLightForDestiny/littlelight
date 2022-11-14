import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class BucketHeaderListItemWidget extends StatelessWidget {
  final int hash;
  final int itemCount;
  final bool isVault;
  final bool canEquip;
  BucketHeaderListItemWidget(this.hash, {this.itemCount = 0, this.isVault = false, this.canEquip = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderWidget(
      child: DefinitionProviderWidget<DestinyInventoryBucketDefinition>(
        hash,
        (definition) => Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: buildLabel(context, definition)),
            buildTrailing(context, definition),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(BuildContext context, DestinyInventoryBucketDefinition definition) {
    return Text(
      definition.displayProperties?.name?.toUpperCase() ?? "",
      softWrap: false,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget buildTrailing(BuildContext context, DestinyInventoryBucketDefinition definition) {
    return Row(children: [
      // BucketDisplayOptionsSelectorWidget(hash: hash, isVault: isVault, isEquippable: canEquip),
      // Container(width: 8),
      buildCount(context, definition),
    ]);
  }

  Widget buildCount(BuildContext context, DestinyInventoryBucketDefinition definition) {
    int bucketSize = definition.itemCount ?? 9;
    if (isVault) {
      return ManifestText<DestinyInventoryBucketDefinition>(
        InventoryBucket.general,
        textExtractor: (def) {
          return "$itemCount/${def.itemCount}";
        },
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      );
    }
    return Text(
      "$itemCount/$bucketSize",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
