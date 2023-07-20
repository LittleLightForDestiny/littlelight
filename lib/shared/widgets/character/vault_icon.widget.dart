import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/bucket_full_helper.dart';
import 'package:little_light/shared/widgets/character/base_character_icon.widget.dart';

class VaultIconWidget extends BaseCharacterIconWidget {
  final int? itemCount;

  const VaultIconWidget({
    double borderWidth = 1.5,
    this.itemCount,
  }) : super(borderWidth: borderWidth);

  @override
  Widget buildIcon(BuildContext context) => Image.asset("assets/imgs/vault-icon.jpg");

  @override
  List<Positioned>? buildOverlays(BuildContext context) {
    if (this.itemCount == null) return null;
    final def = context.definition<DestinyInventoryBucketDefinition>(InventoryBucket.general);
    final isAlmostFull = isBucketAlmostFull(this.itemCount, def);
    if (!isAlmostFull) return null;
    return [
      Positioned(
          right: borderWidth * 2,
          bottom: borderWidth * 2,
          child: Container(
            padding: EdgeInsets.all(2).copyWith(bottom: 0),
            decoration: BoxDecoration(
              color: context.theme.highlightedObjectiveLayers,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "$itemCount",
              style: context.textTheme.highlight.copyWith(height: 1),
            ),
          ))
    ];
  }
}
