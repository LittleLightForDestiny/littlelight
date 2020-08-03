import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

class WishlistsData {
  static BoxDecoration getBoxDecoration(WishlistTag tag) {
    switch (tag) {
      case WishlistTag.GodPVE:
      case WishlistTag.GodPVP:
        return BoxDecoration(
            border: Border.all(color: Colors.amber, width: 1),
            gradient: RadialGradient(
                radius: 1, colors: [getBgColor(tag), Colors.amber]));
      default:
        return BoxDecoration(color: getBgColor(tag));
    }
  }

  static Color getBgColor(WishlistTag tag) {
    switch (tag) {
      case WishlistTag.GodPVE:
      case WishlistTag.PVE:
        return Colors.blue.shade800;
        break;
      case WishlistTag.GodPVP:
      case WishlistTag.PVP:
        return Colors.red.shade800;
        break;
      case WishlistTag.Bungie:
        return Colors.black;

      case WishlistTag.Trash:
        return Colors.lightGreen.shade500;
        break;
    }
    return Colors.amber;
  }

  static Widget getLabel(WishlistTag tag) {
    switch (tag) {
      case WishlistTag.GodPVE:
        return TranslatedTextWidget("PvE godroll");
      case WishlistTag.PVE:
        return TranslatedTextWidget("PvE");
        break;
      case WishlistTag.GodPVP:
        return TranslatedTextWidget("PvP godroll");
      case WishlistTag.PVP:
        return TranslatedTextWidget("PvP");
        break;
      case WishlistTag.Bungie:
        return TranslatedTextWidget("Curated");

      case WishlistTag.Trash:
        return TranslatedTextWidget("Trash");
        break;
    }
    return TranslatedTextWidget("Uncategorized");
  }

  static Widget getIcon(WishlistTag tag, double size) {
    switch (tag) {
      case WishlistTag.GodPVE:
        return Container(
            alignment: Alignment.center,
            child: Icon(LittleLightIcons.vanguard,
                size: size * .8, color: Colors.white));
      case WishlistTag.PVE:
        return Container(
            alignment: Alignment.center,
            child: Icon(LittleLightIcons.vanguard, size: size * .8));
        break;
      case WishlistTag.GodPVP:
        return Container(
            alignment: Alignment.center,
            child: Icon(LittleLightIcons.crucible,
                size: size * .9, color: Colors.white));
      case WishlistTag.PVP:
        return Container(
            alignment: Alignment.center,
            child: Icon(LittleLightIcons.crucible, size: size * .9));
        break;
      case WishlistTag.Bungie:
        return Container(
            alignment: Alignment.center,
            child: Icon(LittleLightIcons.bungie, size: size * .9));

      case WishlistTag.Trash:
        return Container(
            padding: EdgeInsets.all(size * .1),
            child: Image.asset(
              "assets/imgs/trash-roll-icon.png",
            ));
        break;
    }
    return Container(
        alignment: Alignment.center,
        child: Icon(
          Icons.star,
          size: size * .8,
        ));
  }
}
