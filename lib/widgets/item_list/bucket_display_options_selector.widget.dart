import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/user_settings/bucket_display_options.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

class BucketDisplayOptionsSelectorWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final int hash;
  final bool isEquippable;
  final Function onChanged;
  final bool isVault;
  BucketDisplayOptionsSelectorWidget(
      {this.hash, this.isEquippable = false, this.onChanged, this.isVault});
  @override
  BucketDisplayOptionsSelectorWidgetState createState() =>
      new BucketDisplayOptionsSelectorWidgetState();
}

class BucketDisplayOptionsSelectorWidgetState<
    T extends BucketDisplayOptionsSelectorWidget> extends State<T> {
  BucketDisplayType currentType;

  @override
  void initState() {
    super.initState();
    currentType =
        UserSettingsService().getDisplayOptionsForBucket(bucketKey)?.type;
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
    return DropdownButton<BucketDisplayType>(
        items: types.map((t) => buildItem(t)).toList(),
        value: currentType,
        underline: Container(),
        iconEnabledColor: Colors.white,
        icon: Icon(getIcon(currentType)),
        selectedItemBuilder: (context) => types
            .map((t) => Opacity(
                opacity: 0,
                child: Row(children: [
                  getLabel(t),
                  Container(width: 16),
                  Icon(getIcon(t))
                ])))
            .toList(),
        onChanged: (selected) {
          this.currentType = selected;
          UserSettingsService().setDisplayOptionsForBucket(
              bucketKey, BucketDisplayOptions(type: this.currentType));
          setState(() {});
          if (widget.onChanged != null) {
            widget.onChanged();
          }
        });
  }

  DropdownMenuItem<BucketDisplayType> buildItem(BucketDisplayType type) {
    var icon = getIcon(type);
    return DropdownMenuItem<BucketDisplayType>(
        value: type,
        child: Container(
            width: 200,
            child: Row(children: [
              Icon(icon, size: 16),
              Container(width: 8),
              getLabel(type)
            ])));
  }

  Widget getLabel(BucketDisplayType type) {
    switch (type) {
      case BucketDisplayType.Hidden:
        return TranslatedTextWidget("Hidden");
        break;
      case BucketDisplayType.OnlyEquipped:
        return TranslatedTextWidget("Only Equipped");
        break;
      case BucketDisplayType.Large:
        return TranslatedTextWidget("Large");
        break;
      case BucketDisplayType.Medium:
        return TranslatedTextWidget("Medium");
        break;
      case BucketDisplayType.Small:
        return TranslatedTextWidget("Small");
        break;
    }
    return Container();
  }

  IconData getIcon(BucketDisplayType type) {
    switch (type) {
      case BucketDisplayType.Hidden:
        return FontAwesomeIcons.eyeSlash;
        break;
      case BucketDisplayType.OnlyEquipped:
        return LittleLightIcons.icon_display_options_equipped_only;
        break;
      case BucketDisplayType.Large:
        return LittleLightIcons.icon_display_options_list;
        break;
      case BucketDisplayType.Medium:
        return widget.isEquippable
            ? LittleLightIcons.icon_display_options_equipped_with_medium
            : LittleLightIcons.icon_display_options_only_medium;
        break;
      case BucketDisplayType.Small:
        return widget.isEquippable
            ? LittleLightIcons.icon_display_options_equipped_with_small
            : LittleLightIcons.icon_display_options_small_only;
        break;
    }
    return FontAwesomeIcons.eyeSlash;
  }
}
