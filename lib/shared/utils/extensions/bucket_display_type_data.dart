import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';

import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

extension BucketDisplayTypeData on BucketDisplayType {
  bool get availableOnNonEquippableBucket {
    switch (this) {
      case BucketDisplayType.OnlyEquipped:
        return false;
      default:
        return true;
    }
  }

  IconData get equippableIcon {
    switch (this) {
      case BucketDisplayType.Hidden:
        return FontAwesomeIcons.eyeSlash;
      case BucketDisplayType.OnlyEquipped:
        return LittleLightIcons.icon_display_options_equipped_only;
      case BucketDisplayType.Large:
        return LittleLightIcons.icon_display_options_list;
      case BucketDisplayType.Medium:
        return LittleLightIcons.icon_display_options_equipped_with_medium;
      case BucketDisplayType.Small:
        return LittleLightIcons.icon_display_options_equipped_with_small;
    }
  }

  IconData get nonEquippableIcon {
    switch (this) {
      case BucketDisplayType.Hidden:
        return FontAwesomeIcons.eyeSlash;
      case BucketDisplayType.OnlyEquipped:
        return LittleLightIcons.icon_display_options_equipped_only;
      case BucketDisplayType.Large:
        return LittleLightIcons.icon_display_options_list;
      case BucketDisplayType.Medium:
        return LittleLightIcons.icon_display_options_only_medium;
      case BucketDisplayType.Small:
        return LittleLightIcons.icon_display_options_small_only;
    }
  }

  String label(BuildContext context) {
    switch (this) {
      case BucketDisplayType.Hidden:
        return "Hidden".translate(context);
      case BucketDisplayType.OnlyEquipped:
        return "Only Equipped".translate(context);
      case BucketDisplayType.Large:
        return "Large".translate(context);
      case BucketDisplayType.Medium:
        return "Medium".translate(context);
      case BucketDisplayType.Small:
        return "Small".translate(context);
    }
  }

  InventoryItemWidgetDensity? get equippedDensity {
    switch (this) {
      case BucketDisplayType.Hidden:
        return null;
      case BucketDisplayType.OnlyEquipped:
      case BucketDisplayType.Large:
      case BucketDisplayType.Medium:
      case BucketDisplayType.Small:
        return InventoryItemWidgetDensity.High;
    }
  }

  InventoryItemWidgetDensity? get unequippedDensity {
    switch (this) {
      case BucketDisplayType.Hidden:
      case BucketDisplayType.OnlyEquipped:
        return null;
      case BucketDisplayType.Large:
        return InventoryItemWidgetDensity.High;
      case BucketDisplayType.Medium:
        return InventoryItemWidgetDensity.Medium;
      case BucketDisplayType.Small:
        return InventoryItemWidgetDensity.Low;
    }
  }
}
