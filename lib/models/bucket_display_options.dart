import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';

part 'bucket_display_options.g.dart';

extension ListParameters on BucketDisplayOptions {
  double? get unequippedItemHeight {
    switch (type) {
      case BucketDisplayType.Hidden:
      case BucketDisplayType.OnlyEquipped:
        return 0;
      case BucketDisplayType.Large:
        return 96;
      case BucketDisplayType.Medium:
        return 76;
      default:
        return null;
    }
  }

  double? get equippedItemHeight {
    switch (type) {
      case BucketDisplayType.Hidden:
        return 0;
      default:
        return 96;
    }
  }

  int? get unequippedItemsPerRow {
    switch (type) {
      case BucketDisplayType.Hidden:
      case BucketDisplayType.OnlyEquipped:
        return 0;
      case BucketDisplayType.Large:
        return 1;
      case BucketDisplayType.Medium:
        return 3;
      case BucketDisplayType.Small:
        return 5;
    }
  }

  int responsiveUnequippedItemsPerRow(BuildContext context, [int columnCount = 1]) {
    switch (type) {
      case BucketDisplayType.Hidden:
      case BucketDisplayType.OnlyEquipped:
        return 0;
      case BucketDisplayType.Large:
        return 1;
      case BucketDisplayType.Medium:
        if (columnCount >= 2) {
          return MediaQueryHelper(context).responsiveValue(3, desktop: 5);
        }
        return MediaQueryHelper(context).responsiveValue(3, tablet: 5, laptop: 8, desktop: 10);
      case BucketDisplayType.Small:
        if (columnCount >= 3) {
          return MediaQueryHelper(context).responsiveValue(5, laptop: 6, desktop: 9);
        }
        if (columnCount >= 2) {
          return MediaQueryHelper(context).responsiveValue(5, tablet: 6, laptop: 9);
        }
        return MediaQueryHelper(context).responsiveValue(5, tablet: 10, laptop: 15, desktop: 25);
    }
  }
}

enum BucketDisplayType {
  Hidden,
  OnlyEquipped,
  Large,
  Medium,
  Small,
}

@JsonSerializable()
class BucketDisplayOptions {
  final BucketDisplayType type;

  const BucketDisplayOptions({required this.type});

  static BucketDisplayOptions fromJson(dynamic json) {
    return _$BucketDisplayOptionsFromJson(json);
  }

  dynamic toJson() {
    return _$BucketDisplayOptionsToJson(this);
  }
}
