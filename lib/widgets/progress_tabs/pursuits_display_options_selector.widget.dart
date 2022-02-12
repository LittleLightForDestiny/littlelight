// @dart=2.9

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/bucket_display_options.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';
import 'package:little_light/widgets/item_list/bucket_display_options_selector.widget.dart';

class PursuitsDisplayOptionsSelectorWidget extends BucketDisplayOptionsSelectorWidget {
  final String typeIdentifier;
  PursuitsDisplayOptionsSelectorWidget({this.typeIdentifier, Function onChanged}) : super(onChanged: onChanged);
  @override
  PursuitsDisplayOptionsSelectorWidgetState createState() => PursuitsDisplayOptionsSelectorWidgetState();
}

class PursuitsDisplayOptionsSelectorWidgetState
    extends BucketDisplayOptionsSelectorWidgetState<PursuitsDisplayOptionsSelectorWidget> {
  BucketDisplayType currentType;

  @override
  void initState() {
    super.initState();
    currentType = userSettings.getDisplayOptionsForBucket(bucketKey)?.type;
  }

  String get bucketKey {
    return "pursuits_${widget.typeIdentifier}";
  }

  List<BucketDisplayType> get types {
    return [
      BucketDisplayType.Hidden,
      BucketDisplayType.Large,
      BucketDisplayType.Medium,
      BucketDisplayType.Small,
    ];
  }

  DropdownMenuItem<BucketDisplayType> buildItem(BucketDisplayType type) {
    var icon = getIcon(type);
    return DropdownMenuItem<BucketDisplayType>(
        value: type,
        child:
            Container(width: 200, child: Row(children: [Icon(icon, size: 16), Container(width: 8), getLabel(type)])));
  }

  Widget getLabel(BucketDisplayType type) {
    switch (type) {
      case BucketDisplayType.Hidden:
        return TranslatedTextWidget("Hidden");

      case BucketDisplayType.OnlyEquipped:
        return TranslatedTextWidget("Only Equipped");

      case BucketDisplayType.Large:
        return TranslatedTextWidget("Large");

      case BucketDisplayType.Medium:
        return TranslatedTextWidget("Medium");

      case BucketDisplayType.Small:
        return TranslatedTextWidget("Small");
    }
    return Container();
  }

  IconData getIcon(BucketDisplayType type) {
    switch (type) {
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
    return FontAwesomeIcons.eyeSlash;
  }
}
