import 'package:flutter/material.dart';
import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/enums/damage_type_enum.dart';
import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/enums/destiny_ammunition_type_enum.dart';
import 'package:little_light/widgets/icon_fonts/destiny_icons_icons.dart';

class DestinyData {
  static const Color positiveFeedback = Color.fromRGBO(67, 205, 57, 1);
  static const Color negativeFeedback = Color.fromRGBO(204, 58, 56, 1);

  static const int collectionsRootHash = 3790247699;

  static const List<int> statWhitelist = [
    3614673599, // Blast Radius
    2523465841, // Velocity
    4043523819, // Impact
    1240592695, // Range
    155624089, // Stability
    943549884, // Handling
    4188031367, // Reload Speed

    1345609583, // Aim Assistance
    2715839340, // Recoil Direction
    3555269338, // Zoom

    4284893193, // Rounds Per Minute
    2961396640, // Charge Time
    3871231066, // Magazine
    1931675084, //Inventory Size

    2996146975, // Mobility
    392767087, // Resilience
    1943323491, //recovery
  ];
  
  static const List<int> socketCategoryPerkHashes = [
    319279448, // sparrow perks
    1576735337, //clan banner perks
    1683579090, // clan perks
    2278110604, // vehicle perks
    2518356196, //armor perks
    3301318876, //ghost shell perks
    3898156960, // clan perks (again?)
    4241085061, //weapon perks
  ];

  static const List<int> socketCategoryModHashes = [
    279738248, // emblem customization
    590099826, // armor mods
    1093090108, // emotes
    2622243744, // nightfall modifiers
    2685412949, //weapon mods
    3379164649, //ghost shell mods
    3954618873, // clan staves
    4243480345, //vehicle mods
    4265082475, //vehicle mods
  ];

  static IconData getClassIcon(int type) {
    switch (type) {
      case DestinyClass.Hunter:
        return DestinyIcons.class_hunter;
      case DestinyClass.Titan:
        return DestinyIcons.class_titan;
      case DestinyClass.Warlock:
        return DestinyIcons.class_warlock;
    }
    return DestinyIcons.destiny;
  }

  static IconData getAmmoTypeIcon(int type) {
    switch (type) {
      case DestinyAmmunitionType.Primary:
        return DestinyIcons.ammo_primary;
      case DestinyAmmunitionType.Special:
        return DestinyIcons.ammo_special;
      case DestinyAmmunitionType.Heavy:
        return DestinyIcons.ammo_heavy;
    }
    return DestinyIcons.destiny;
  }

  static Color getAmmoTypeColor(int type) {
    switch (type) {
      case DestinyAmmunitionType.Special:
        return Color.fromARGB(255, 116, 247, 146);
      case DestinyAmmunitionType.Heavy:
        return Color.fromARGB(255, 179, 127, 251);
    }
    return Colors.white;
  }

  static IconData getDamageTypeIcon(int type) {
    switch (type) {
      case DamageType.Kinetic:
        return DestinyIcons.damage_kinetic;
      case DamageType.Arc:
        return DestinyIcons.damage_arc;
      case DamageType.Thermal:
        return DestinyIcons.damage_solar;
      case DamageType.Void:
        return DestinyIcons.damage_void;
    }
    return DestinyIcons.destiny;
  }

  static Color getDamageTypeColor(int damageType) {
    switch (damageType) {
      case DamageType.Arc:
        return Color.fromARGB(255, 118, 186, 230);
      case DamageType.Thermal:
        return Color.fromARGB(255, 243, 98, 39);
      case DamageType.Void:
        return Color.fromARGB(255, 64, 34, 101);
    }
    return Colors.white;
  }

  static Color getDamageTypeTextColor(int damageType) {
    switch (damageType) {
      case DamageType.Arc:
        return Color.fromARGB(255, 130, 200, 253);
      case DamageType.Thermal:
        return Color.fromARGB(255, 255, 156, 74);
      case DamageType.Void:
        return Color.fromARGB(255, 177, 120, 248);
    }
    return Colors.white;
  }

  static Color getTierColor(int tierType) {
    switch (tierType) {
      case TierType.Basic:
        return Color.fromARGB(255, 195, 188, 180);
      case TierType.Common:
        return Color.fromARGB(255, 48, 107, 61);
      case TierType.Rare:
        return Color.fromARGB(255, 80, 118, 163);
      case TierType.Superior:
        return Color.fromARGB(255, 82, 47, 101);
      case TierType.Exotic:
        return Color.fromARGB(255, 206, 174, 51);
    }
    return Color.fromARGB(255, 0, 0, 0);
  }

  static Color getTierTextColor(int tierType) {
    switch (tierType) {
      case TierType.Basic:
        return Colors.grey.shade800;
    }
    return Colors.white;
  }
}

class ProgressionHash {
  static const String Overlevel = '2030054750';
}
