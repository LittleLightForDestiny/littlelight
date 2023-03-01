// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_item_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_list/bucket_header.widget.dart';
import 'package:little_light/widgets/progress_tabs/pursuits_display_options_selector.widget.dart';

class PursuitCategoryHeaderWidget extends BucketHeaderWidget {
  @override
  final Function onChanged;
  final String label;
  const PursuitCategoryHeaderWidget(
      {this.onChanged, Key key, this.label, int hash, int itemCount})
      : super(key: key, hash: hash, itemCount: itemCount);
  @override
  PursuitCategoryHeaderWidgetState createState() =>
      PursuitCategoryHeaderWidgetState();
}

class PursuitCategoryHeaderWidgetState
    extends BucketHeaderWidgetState<PursuitCategoryHeaderWidget>
    with ManifestConsumer {
  @override
  fetchDefinition() async {
    bucketDef = await manifest.getDefinition<DestinyInventoryBucketDefinition>(
        InventoryBucket.pursuits);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget buildLabel(BuildContext context) {
    TextStyle style = const TextStyle(fontWeight: FontWeight.bold);
    if (widget.hash != null) {
      return ManifestText<DestinyItemCategoryDefinition>(
        widget.hash,
        uppercase: true,
        style: style,
      );
    }
    if ((widget.label?.length ?? 0) > 0) {
      return Text(
        widget.label.toUpperCase(),
        style: style,
      );
    }
    return TranslatedTextWidget(
      "Other",
      uppercase: true,
      style: style,
    );
  }

  @override
  buildTrailing(BuildContext context) {
    return Row(children: [
      PursuitsDisplayOptionsSelectorWidget(
          typeIdentifier: "${widget.hash}_${widget.label}",
          onChanged: widget.onChanged),
      Container(width: 8),
      buildCount(context),
    ]);
  }

  @override
  buildCount(BuildContext context) {
    int bucketSize = bucketDef?.itemCount ?? 0;
    if (widget.hash == InventoryBucket.subclass) {
      bucketSize = 3;
    }
    if (widget.isVault) {
      return ManifestText<DestinyInventoryBucketDefinition>(
        InventoryBucket.general,
        textExtractor: (def) {
          return "${widget.itemCount}/${def.itemCount}";
        },
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      );
    }
    return Text(
      "${widget.itemCount}/$bucketSize",
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
