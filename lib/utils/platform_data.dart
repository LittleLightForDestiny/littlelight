import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

class PlatformData {
  Color color;
  IconData iconData;
  String name;
  PlatformData(this.name, this.iconData, this.color);

  static PlatformData getPlatform(BungieMembershipType type) {
    switch (type) {
      case BungieMembershipType.TigerXbox:
        return PlatformData("Xbox Live", LittleLightIcons.platform_xbox,
            Color.fromARGB(255, 93, 194, 30));

      case BungieMembershipType.TigerPsn:
        return PlatformData(
            "Playstation Network",
            LittleLightIcons.platform_playstation,
            Color.fromARGB(255, 0, 55, 145));

      case BungieMembershipType.TigerBlizzard:
        return PlatformData("Battle.net", LittleLightIcons.platform_blizzard,
            Color.fromARGB(255, 0, 180, 255));

      case BungieMembershipType.TigerSteam:
        return PlatformData("Steam", LittleLightIcons.platform_steam,
            Color.fromARGB(255, 0, 172, 236));

      case BungieMembershipType.TigerStadia:
        return PlatformData("Stadia", LittleLightIcons.platform_stadia,
            Color.fromARGB(255, 205, 38, 64));

      default:
        return PlatformData("Unknown", Icons.not_interested, Colors.black);
    }
  }
}
