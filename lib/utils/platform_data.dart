import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

extension MembershipPlatformData on BungieMembershipType {
  PlatformData get data => PlatformData.getPlatform(this);
  IconData get icon => data.icon;
  String get name => data.name;
  Color get color => data.color;
}

class PlatformData {
  Color color;
  IconData icon;
  String name;
  PlatformData(this.name, this.icon, this.color);

  static PlatformData getPlatform(BungieMembershipType type) {
    switch (type) {
      case BungieMembershipType.TigerXbox:
        return PlatformData("Xbox Live", LittleLightIcons.platform_xbox,
            const Color.fromARGB(255, 93, 194, 30));

      case BungieMembershipType.TigerPsn:
        return PlatformData(
            "Playstation Network",
            LittleLightIcons.platform_playstation,
            const Color.fromARGB(255, 0, 55, 145));

      case BungieMembershipType.TigerBlizzard:
        return PlatformData("Battle.net", LittleLightIcons.platform_blizzard,
            const Color.fromARGB(255, 0, 180, 255));

      case BungieMembershipType.TigerSteam:
        return PlatformData("Steam", LittleLightIcons.platform_steam,
            const Color.fromARGB(255, 42, 71, 94));

      case BungieMembershipType.TigerStadia:
        return PlatformData("Stadia", LittleLightIcons.platform_stadia,
            const Color.fromARGB(255, 205, 38, 64));

      default:
        return PlatformData("Unknown", Icons.not_interested, Colors.black);
    }
  }

  static PlatformData get crossPlayData => PlatformData("Bungie cross save",
      LittleLightIcons.cross_save, const Color.fromARGB(255, 0, 180, 255));
}
