import 'package:bungie_api/enums/damage_type.dart';
import 'package:bungie_api/enums/destiny_ammunition_type.dart';
import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/enums/destiny_energy_type.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

export '../shared/utils/extensions/element_type_data.dart';

class RaidPhases {
  static const int leviathanGardens = 3847906370;
  static const int leviathanPools = 2188993306;
  static const int leviathanArena = 1431486395;
  static const int leviathanCallus = 4231923662;

  static const int eowLoyalists = 415534662;
  static const int eowRings = 3813639709;
  static const int eowShields = 2941618871;
  static const int eowArgos = 877738674;

  static const int sosStatueGarden = 3864507933;
  static const int sosConduitRoom = 3025298087;
  static const int sosShips = 1245655652;
  static const int sosValCauor = 1245655655;

  static const int lwKalli = 1126840038;
  static const int lwShuroChi = 1040714588;
  static const int lwMorgeth = 4249034918;
  static const int lwVault = 436847112;
  static const int lwRiven = 2392610624;

  static const int sotpBotzaDistrict = 566861111;
  static const int sotpVaultAccess = 244769953;
  static const int sotpInsurectionPrime = 1268191778;

  static const int cosRitual = 824306255;
  static const int cosInfiltration = 9235511;
  static const int cosDeception = 3789028322;
  static const int cosGahlran = 3307986266;

  static const int gosEvasion = 2158557525;
  static const int gosSummon = 3736477924;
  static const int gosConsecratedMind = 1024471091;
  static const int gosSanctifieddMind = 523815399;

  static const int leviathanPoolsChallenge = 3796634159;
  static const int sotpInsurrectionPrimeChallenge = 4140089399;
}

extension DestinyClassData on DestinyClass {
  IconData get icon {
    switch (this) {
      case DestinyClass.Hunter:
        return LittleLightIcons.class_hunter;
      case DestinyClass.Titan:
        return LittleLightIcons.class_titan;
      case DestinyClass.Warlock:
        return LittleLightIcons.class_warlock;
      default:
        return LittleLightIcons.destiny;
    }
  }
}

class DestinyData {
  static const Color trackingOnColor = Color(0xFF43A047);
  static const Color trackingOffColor = Color(0xFF2E7D32);

  static const Color perkColor = Color.fromRGBO(94, 153, 192, 1);

  static const Color objectiveProgress = Color.fromRGBO(90, 163, 102, 1);

  static const List<int> noBarStats = [
    4284893193, // Rounds Per Minute
    3871231066, // Magazine
    2961396640, // Charge Time
    1931675084, //Inventory Size
  ];

  static const List<int> hiddenStats = [
    1345609583, // Aim Assistance
    2715839340, // Recoil Direction
    3555269338, // Zoom
  ];

  static const socketCategoryIntrinsicPerkHashes = [
    3154740035, //armor perks
    3956125808, //weapon perks
  ];

  static const List<int> socketCategoryTierHashes = [
    760375309, // armor tier
  ];

  static const List<int> socketCategoryCosmeticModHashes = [
    1926152773, // armor cosmetics
    2048875504, // weapon mods
  ];

  @deprecated
  static IconData getClassIcon(DestinyClass type) {
    return type.icon;
  }

  static IconData getAmmoTypeIcon(DestinyAmmunitionType type) {
    switch (type) {
      case DestinyAmmunitionType.Primary:
        return LittleLightIcons.ammo_primary;
      case DestinyAmmunitionType.Special:
        return LittleLightIcons.ammo_special;
      case DestinyAmmunitionType.Heavy:
        return LittleLightIcons.ammo_heavy;

      default:
        return LittleLightIcons.destiny;
    }
  }

  static Color getAmmoTypeColor(DestinyAmmunitionType type) {
    switch (type) {
      case DestinyAmmunitionType.Special:
        return const Color.fromARGB(255, 116, 247, 146);
      case DestinyAmmunitionType.Heavy:
        return const Color.fromARGB(255, 179, 127, 251);

      default:
        return LittleLightThemeData().onSurfaceLayers;
    }
  }

  static IconData getDamageTypeIcon(DamageType type) {
    switch (type) {
      case DamageType.Kinetic:
        return LittleLightIcons.damage_kinetic;
      case DamageType.Arc:
        return LittleLightIcons.damage_arc;
      case DamageType.Thermal:
        return LittleLightIcons.damage_solar;
      case DamageType.Void:
        return LittleLightIcons.damage_void;
      case DamageType.Stasis:
        return LittleLightIcons.damage_stasis;

      default:
        return LittleLightIcons.destiny;
    }
  }

  static IconData? getEnergyTypeIcon(DestinyEnergyType type) {
    switch (type) {
      case DestinyEnergyType.Arc:
        return LittleLightIcons.damage_arc;
      case DestinyEnergyType.Thermal:
        return LittleLightIcons.damage_solar;
      case DestinyEnergyType.Void:
        return LittleLightIcons.damage_void;
      case DestinyEnergyType.Stasis:
        return LittleLightIcons.damage_stasis;

      default:
        return null;
    }
  }

  static int? getEnergyTypeCostHash(DestinyEnergyType damageType) {
    switch (damageType) {
      case DestinyEnergyType.Arc:
        return 3779394102;
      case DestinyEnergyType.Thermal:
        return 3344745325;
      case DestinyEnergyType.Void:
        return 2399985800;
      case DestinyEnergyType.Stasis:
        return 998798867;

      default:
        return null;
    }
  }
}

class ProgressionHash {
  static const int Power = 1935470627;
}

enum CurrencyConversionType { InventoryItem, Currency }

class CurrencyConversion {
  static const Map<int, CurrencyConversion> purchaseables = {
    924468777: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 1305274547), //Phaseglass
    3721881826: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 950899352), //Dusklight
    1420498062: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 49145143), //Simulation Seeds
    1812969468: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 3853748946), //Enhancement Cores
    4153440841: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 2014411539), //Alkane Dust
    1845310989: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 3487922223), //Datalattice
    2536947844: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 31293053), //Seraphite
    3245502278: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 1177810185), //Etheric Spiral
    778553120: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 592227263), //Baryon Bough
    1923884703: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 3592324052), //Helium Filaments
    4106973372: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 293622383), //Spinmetal
    1760701414: CurrencyConversion(
        CurrencyConversionType.InventoryItem, 1485756901), //Glacial Starwort
    2654422615: CurrencyConversion(
        CurrencyConversionType.Currency, 1022552290), //Legendary Shards
    3664001560: CurrencyConversion(
        CurrencyConversionType.Currency, 3159615086), //Glimmer
  };

  final CurrencyConversionType type;
  final int hash;

  const CurrencyConversion(this.type, this.hash);
}
