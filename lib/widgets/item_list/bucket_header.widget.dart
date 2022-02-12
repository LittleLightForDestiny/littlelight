// @dart=2.9

import 'package:flutter/material.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_list/bucket_display_options_selector.widget.dart';

class BucketHeaderWidget extends StatefulWidget {
  final int hash;
  final int itemCount;
  final bool isVault;
  final bool isEquippable;
  final Function onChanged;
  BucketHeaderWidget(
      {this.hash, this.itemCount = 0, this.isVault = false, this.isEquippable = false, this.onChanged, Key key})
      : super(key: key);
  @override
  BucketHeaderWidgetState createState() => BucketHeaderWidgetState();
}

class BucketHeaderWidgetState<T extends BucketHeaderWidget> extends State<T> with ManifestConsumer {
  DestinyInventoryBucketDefinition bucketDef;

  @override
  void initState() {
    super.initState();
    if (bucketDef == null) {
      fetchDefinition();
    }
  }

  fetchDefinition() async {
    bucketDef = await manifest.getDefinition<DestinyInventoryBucketDefinition>(widget.hash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderWidget(
        child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Expanded(child: buildLabel(context)), buildTrailing(context)]));
  }

  buildLabel(BuildContext context) {
    return Text(
      bucketDef?.displayProperties?.name?.toUpperCase() ?? "",
      softWrap: false,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  buildTrailing(BuildContext context) {
    return Row(children: [
      BucketDisplayOptionsSelectorWidget(
          hash: widget.hash, isVault: widget.isVault, isEquippable: widget.isEquippable, onChanged: widget.onChanged),
      Container(width: 8),
      buildCount(context),
    ]);
  }

  buildCount(BuildContext context) {
    int bucketSize = bucketDef?.itemCount ?? 9;
    if (widget.hash == InventoryBucket.subclass) {
      bucketSize = 4;
    }
    if (widget.isVault) {
      return ManifestText<DestinyInventoryBucketDefinition>(
        InventoryBucket.general,
        textExtractor: (def) {
          return "${widget.itemCount}/${def.itemCount}";
        },
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      );
    }
    return Text(
      "${widget.itemCount}/$bucketSize",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
