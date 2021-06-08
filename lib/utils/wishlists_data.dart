import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/center_icon_workaround.dart';
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

      case WishlistTag.Controller:
        return BoxDecoration(
            border: Border.all(color: Colors.blueGrey.shade800, width: 1),
            color: Colors.blueGrey.shade200);

      case WishlistTag.Mouse:
        return BoxDecoration(
            border: Border.all(color: Colors.blueGrey.shade200, width: 1),
            color: Colors.blueGrey.shade800);
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

      case WishlistTag.Controller:
        return Colors.blueGrey.shade800;

      case WishlistTag.Mouse:
        return Colors.blueGrey.shade200;

      case WishlistTag.Trash:
        return Colors.lightGreen.shade500;
        break;

      default:
        return Colors.amber;
    }
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
      default:
        return TranslatedTextWidget("Uncategorized");
    }
  }

  static Widget getIcon(WishlistTag tag, double size) {
    switch (tag) {
      case WishlistTag.GodPVE:
        return Container(
            alignment: Alignment.center,
            child: CenterIconWorkaround(LittleLightIcons.vanguard,
                size: size * .8, color: Colors.white));
      case WishlistTag.PVE:
        return Container(
            alignment: Alignment.center,
            child: CenterIconWorkaround(LittleLightIcons.vanguard,
                size: size * .8));
        break;
      case WishlistTag.GodPVP:
        return Container(
            alignment: Alignment.center,
            child: CenterIconWorkaround(LittleLightIcons.crucible,
                size: size * .9, color: Colors.white));
      case WishlistTag.PVP:
        return Container(
            alignment: Alignment.center,
            child: CenterIconWorkaround(LittleLightIcons.crucible,
                size: size * .9));
        break;
      case WishlistTag.Bungie:
        return Container(
            alignment: Alignment.center,
            child:
                CenterIconWorkaround(LittleLightIcons.bungie, size: size * .9));

      case WishlistTag.Trash:
        return Container(
            padding: EdgeInsets.all(size * .1),
            child: Image.asset(
              "assets/imgs/trash-roll-icon.png",
            ));
        break;

      case WishlistTag.Controller:
        return Container(
            alignment: Alignment.center,
            child: CenterIconWorkaround(
              FontAwesomeIcons.gamepad,
              size: size * .6,
              color: Colors.blueGrey.shade800,
            ));

      case WishlistTag.Mouse:
        return Container(
            alignment: Alignment.center,
            child: CenterIconWorkaround(
              FontAwesomeIcons.mouse,
              size: size * .7,
              color: Colors.blueGrey.shade200,
            ));

      default:
        return Container(
            alignment: Alignment.center,
            child: CenterIconWorkaround(
              Icons.star,
              size: size * .8,
            ));
    }
  }
}
