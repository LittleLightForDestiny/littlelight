// @dart=2.9

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';
import 'package:little_light/widgets/item_list/bucket_display_options_selector.widget.dart';

class PursuitsDisplayOptionsSelectorWidget extends BucketDisplayOptionsSelectorWidget {
  final String typeIdentifier;
  const PursuitsDisplayOptionsSelectorWidget({this.typeIdentifier, Function onChanged}) : super(onChanged: onChanged);
  @override
  PursuitsDisplayOptionsSelectorWidgetState createState() => PursuitsDisplayOptionsSelectorWidgetState();
}

class PursuitsDisplayOptionsSelectorWidgetState
    extends BucketDisplayOptionsSelectorWidgetState<PursuitsDisplayOptionsSelectorWidget> {
  @override
  BucketDisplayType currentType;

  @override
  void initState() {
    super.initState();
    currentType = userSettings.getDisplayOptionsForBucket(bucketKey)?.type;
  }

  @override
  String get bucketKey {
    return "pursuits_${widget.typeIdentifier}";
  }

  @override
  List<BucketDisplayType> get types {
    return [
      BucketDisplayType.Hidden,
      BucketDisplayType.Large,
      BucketDisplayType.Medium,
      BucketDisplayType.Small,
    ];
  }

  @override
  DropdownMenuItem<BucketDisplayType> buildItem(BucketDisplayType type) {
    var icon = getIcon(type);
    return DropdownMenuItem<BucketDisplayType>(
        value: type,
        child:
            SizedBox(width: 200, child: Row(children: [Icon(icon, size: 16), Container(width: 8), getLabel(type)])));
  }

  @override
  Widget getLabel(BucketDisplayType type) {
    switch (type) {
      case BucketDisplayType.Hidden:
        return Text("Hidden".translate(context));

      case BucketDisplayType.OnlyEquipped:
        return Text("Only Equipped".translate(context));

      case BucketDisplayType.Large:
        return Text("Large".translate(context));

      case BucketDisplayType.Medium:
        return Text("Medium".translate(context));

      case BucketDisplayType.Small:
        return Text("Small".translate(context));
    }
    return Container();
  }

  @override
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
