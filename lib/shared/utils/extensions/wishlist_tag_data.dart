import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

extension HelperMethods on Set<WishlistTag> {
  bool get isPvE => contains(WishlistTag.GodPVE) || contains(WishlistTag.PVE);
  bool get isPvP => contains(WishlistTag.GodPVP) || contains(WishlistTag.PVP);
  bool get isAllAround => isPvE && isPvP;
}

extension WishlistTagData on WishlistTag {
  Color getBorderColor(BuildContext context) {
    switch (this) {
      case WishlistTag.GodPVE:
      case WishlistTag.GodPVP:
        return context.theme.achievementLayers.layer1;
      case WishlistTag.PVE:
      case WishlistTag.PVP:
      case WishlistTag.Bungie:
      case WishlistTag.Trash:
      case WishlistTag.Mouse:
      case WishlistTag.Controller:
      case WishlistTag.UnknownEnumValue:
        return getColor(context);
    }
  }

  Color getForegroundColor(BuildContext context) {
    switch (this) {
      case WishlistTag.GodPVE:
      case WishlistTag.GodPVP:
        return context.theme.achievementLayers.layer1;
      case WishlistTag.PVE:
      case WishlistTag.PVP:
      case WishlistTag.Bungie:
      case WishlistTag.Trash:
      case WishlistTag.Mouse:
      case WishlistTag.Controller:
      case WishlistTag.UnknownEnumValue:
        return context.theme.onSurfaceLayers;
    }
  }

  IconData getIcon(BuildContext context) {
    switch (this) {
      case WishlistTag.GodPVE:
      case WishlistTag.PVE:
        return LittleLightIcons.vanguard;
      case WishlistTag.GodPVP:
      case WishlistTag.PVP:
        return LittleLightIcons.crucible;
      case WishlistTag.Bungie:
        return LittleLightIcons.bungie;
      case WishlistTag.Trash:
        return FontAwesomeIcons.trash;
      case WishlistTag.Mouse:
        return FontAwesomeIcons.computerMouse;
      case WishlistTag.Controller:
        return FontAwesomeIcons.gamepad;
      case WishlistTag.UnknownEnumValue:
        return FontAwesomeIcons.question;
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case WishlistTag.GodPVE:
      case WishlistTag.PVE:
        return const Color(0xFF457FD6);
      case WishlistTag.GodPVP:
      case WishlistTag.PVP:
        return const Color(0xFFDF5555);
      case WishlistTag.Bungie:
        return const Color(0xFF343030);
      case WishlistTag.Trash:
        return const Color(0xFF980B0B);
      case WishlistTag.Mouse:
      case WishlistTag.Controller:
        return const Color(0xFF4B555B);
      case WishlistTag.UnknownEnumValue:
        return Colors.transparent;
    }
  }
}
