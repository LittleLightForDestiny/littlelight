import 'package:bungie_api/enums/bungie_membership_type_enum.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/icon_fonts/destiny_icons_icons.dart';

class PlatformData{
  Color color;
  IconData iconData;
  String name;
  PlatformData(this.name, this.iconData, this.color);

  static PlatformData getPlatform(int type){
    switch (type) {
      case BungieMembershipType.TigerXbox:
      return PlatformData("Xbox Live", DestinyIcons.platform_xbox, Color.fromARGB(255, 93, 194, 30));
      
      case BungieMembershipType.TigerPsn:
      return PlatformData("Playstation Network", DestinyIcons.platform_playstation, Color.fromARGB(255, 0, 55, 145));

      case BungieMembershipType.TigerBlizzard:
      return PlatformData("Battle.net", DestinyIcons.platform_blizzard, Color.fromARGB(255, 0, 180, 255));

      case BungieMembershipType.TigerSteam:
      return PlatformData("Steam", DestinyIcons.platform_steam, Color.fromARGB(255, 0, 172, 236));
    }
    return PlatformData("Unknown", Icons.not_interested, Colors.black);
  }
}