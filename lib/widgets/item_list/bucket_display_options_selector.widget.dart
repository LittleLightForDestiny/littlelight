import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

class BucketDisplayOptionsSelectorWidget extends StatefulWidget {
  final int? hash;
  final bool isEquippable;
  final Function? onChanged;
  final bool isVault;
  BucketDisplayOptionsSelectorWidget({this.hash, this.isEquippable = false, this.onChanged, this.isVault = false});
  @override
  BucketDisplayOptionsSelectorWidgetState createState() => BucketDisplayOptionsSelectorWidgetState();
}

class BucketDisplayOptionsSelectorWidgetState<T extends BucketDisplayOptionsSelectorWidget> extends State<T>
    with UserSettingsConsumer {
  BucketDisplayType? currentType;

  @override
  void initState() {
    super.initState();
    currentType = userSettings.getDisplayOptionsForBucket(bucketKey)?.type;
  }

  String get bucketKey {
    return widget.isVault ? "vault_${widget.hash}" : "${widget.hash}";
  }

  List<BucketDisplayType> get types {
    if (widget.isEquippable) {
      return [
        BucketDisplayType.Hidden,
        BucketDisplayType.OnlyEquipped,
        BucketDisplayType.Large,
        BucketDisplayType.Medium,
        BucketDisplayType.Small,
      ];
    } else {
      return [
        BucketDisplayType.Hidden,
        BucketDisplayType.Large,
        BucketDisplayType.Medium,
        BucketDisplayType.Small,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 20,
        child: Stack(clipBehavior: Clip.none, alignment: Alignment.centerRight, children: [
          Positioned(
              top: -10,
              right: 0,
              child: DropdownButton<BucketDisplayType>(
                  items: types.map((t) => buildItem(t)).toList(),
                  value: currentType,
                  underline: Container(),
                  iconEnabledColor: Theme.of(context).colorScheme.onSurface,
                  icon: Icon(getIcon(currentType)),
                  selectedItemBuilder: (context) => types
                      .map((t) => Opacity(
                          opacity: 0, child: Row(children: [getLabel(t), Container(width: 16), Icon(getIcon(t))])))
                      .toList(),
                  onChanged: (selected) {
                    this.currentType = selected;
                    if (selected == null) return;
                    userSettings.setDisplayOptionsForBucket(bucketKey, BucketDisplayOptions(type: selected));
                    setState(() {});
                    widget.onChanged?.call();
                  }))
        ]));
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
  }

  IconData? getIcon(BucketDisplayType? type) {
    switch (type) {
      case BucketDisplayType.Hidden:
        return FontAwesomeIcons.eyeSlash;
      case BucketDisplayType.OnlyEquipped:
        return LittleLightIcons.icon_display_options_equipped_only;
      case BucketDisplayType.Large:
        return LittleLightIcons.icon_display_options_list;
      case BucketDisplayType.Medium:
        return widget.isEquippable
            ? LittleLightIcons.icon_display_options_equipped_with_medium
            : LittleLightIcons.icon_display_options_only_medium;
      case BucketDisplayType.Small:
        return widget.isEquippable
            ? LittleLightIcons.icon_display_options_equipped_with_small
            : LittleLightIcons.icon_display_options_small_only;
      case null:
        return null;
    }
  }
}
