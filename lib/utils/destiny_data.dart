import 'package:flutter/material.dart';
import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/enums/damage_type_enum.dart';
import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/enums/destiny_ammunition_type_enum.dart';
import 'package:little_light/widgets/icon-fonts/destiny_icons_icons.dart';

class DestinyData{
  static IconData getClassIcon(int type){
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

  static IconData getAmmoTypeIcon(int type){
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

  static Color getAmmoTypeColor(int type){
    switch (type) {
      case DestinyAmmunitionType.Special:
      return Color.fromARGB(255, 116, 247, 146);
      case DestinyAmmunitionType.Heavy:
      return Color.fromARGB(255, 179, 127, 251);
    }
    return Colors.white;
  }

  static IconData getDamageTypeIcon(int type){
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

  static Color getDamageTypeColor(int damageType){
    switch(damageType){
      case DamageType.Arc:
        return Color.fromARGB(255, 118,186,230);
      case DamageType.Thermal:
        return Color.fromARGB(255, 243,98,39);
      case DamageType.Void:
        return Color.fromARGB(255, 64,34,101);
    }
    return Colors.white;
  }

  static Color getDamageTypeTextColor(int damageType){
    switch(damageType){
      case DamageType.Arc:
        return Color.fromARGB(255, 130,200,253);
      case DamageType.Thermal:
        return Color.fromARGB(255, 255,156,74);
      case DamageType.Void:
        return Color.fromARGB(255, 177,120,248);
    }
    return Colors.white;
  }


  static Color getTierColor(int tierType){
    switch(tierType){
      case TierType.Basic:
        return Color.fromARGB(255, 195,188,180);
      case TierType.Common:
        return Color.fromARGB(255, 48,107,61);
      case TierType.Rare:
        return Color.fromARGB(255, 80,118,163);
      case TierType.Superior:
        return Color.fromARGB(255, 82,47,101);
      case TierType.Exotic:
        return Color.fromARGB(255, 206,174,51);
    }
    return Color.fromARGB(255, 0, 0, 0);
  }

  static Color getTierTextColor(int tierType){
    switch(tierType){
      case TierType.Basic:
        return Colors.grey.shade800;
    }
    return Colors.white;
  }
}

class ProgressionHash{
  static const String Overlevel = '2030054750';
}