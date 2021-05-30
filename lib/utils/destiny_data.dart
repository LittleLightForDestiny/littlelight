import 'package:bungie_api/enums/damage_type.dart';
import 'package:bungie_api/enums/destiny_ammunition_type.dart';
import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/enums/destiny_energy_type.dart';
import 'package:bungie_api/enums/destiny_item_sub_type.dart';
import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/enums/tier_type.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

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

class DestinyData {
  static const Map<DamageType, int> damageTypeHashes = {
    DamageType.Kinetic: 3373582085,
    DamageType.Thermal: 1847026933,
    DamageType.Arc: 2303181850,
    DamageType.Void: 3454344768,
  };

  static const Map<TierType, int> tierTypeHashes = {
    TierType.Basic: 3340296461,
    TierType.Common: 2395677314,
    TierType.Rare: 2127292149,
    TierType.Superior: 4008398120,
    TierType.Exotic: 2759499571,
  };

  static const Map<DestinyClass, int> classTypeHashes = {
    DestinyClass.Titan: 3655393761,
    DestinyClass.Hunter: 671679327,
    DestinyClass.Warlock: 2271682572,
  };

  static const Map<DestinyAmmunitionType, int> ammoTypeHashes = {
    DestinyAmmunitionType.Primary: 1731162900,
    DestinyAmmunitionType.Special: 638914517,
    DestinyAmmunitionType.Heavy: 3686962409,
  };

  static const Map<DestinyItemType, int> itemTypeHashes = {
    DestinyItemType.Subclass: 0,
    DestinyItemType.Weapon: 1,
    DestinyItemType.Armor: 20,
    DestinyItemType.Quest: 53,
    DestinyItemType.QuestStep: 16,
    DestinyItemType.Bounty: 1784235469,
    DestinyItemType.Ghost: 39,
    DestinyItemType.Vehicle: 43,
    DestinyItemType.Ship: 42,
    DestinyItemType.Emblem: 19,
    DestinyItemType.Aura: 57,
    DestinyItemType.ClanBanner: 874645359,
    DestinyItemType.Emote: 44,
    DestinyItemType.Mod: 59,
    DestinyItemType.Engram: 34,
    DestinyItemType.Consumable: 35,
    DestinyItemType.Currency: 18,
    DestinyItemType.Dummy: 3109687656,
    DestinyItemType.Package: 268598612,
  };

  static const Map<DestinyItemSubType, int> itemSubtypeHashes = {
    DestinyItemSubType.AutoRifle: 5,
    DestinyItemSubType.Shotgun: 11,
    DestinyItemSubType.Machinegun: 12,
    DestinyItemSubType.HandCannon: 6,
    DestinyItemSubType.RocketLauncher: 13,
    DestinyItemSubType.FusionRifle: 9,
    DestinyItemSubType.SniperRifle: 10,
    DestinyItemSubType.PulseRifle: 7,
    DestinyItemSubType.ScoutRifle: 8,
    DestinyItemSubType.Sidearm: 14,
    DestinyItemSubType.Sword: 54,
    DestinyItemSubType.Mask: 55,
    DestinyItemSubType.Shader: 41,
    DestinyItemSubType.FusionRifleLine: 1504945536,
    DestinyItemSubType.GrenadeLauncher: 153950757,
    DestinyItemSubType.SubmachineGun: 3954685534,
    DestinyItemSubType.TraceRifle: 2489664120,
    DestinyItemSubType.HelmetArmor: 45,
    DestinyItemSubType.GauntletsArmor: 46,
    DestinyItemSubType.ChestArmor: 47,
    DestinyItemSubType.LegArmor: 48,
    DestinyItemSubType.ClassArmor: 49,
    DestinyItemSubType.Bow: 3317538576,
  };

  static const Color positiveFeedback = Color.fromRGBO(67, 205, 57, 1);
  static const Color negativeFeedback = Color.fromRGBO(204, 58, 56, 1);
  static const Color masterworkColor = Color.fromRGBO(235, 196, 98, 1);

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

  static const List<int> armorStats = [
    2996146975, // Mobility
    392767087, // Resilience
    1943323491, //recovery
  ];

  static const List<int> hiddenStats = [
    1345609583, // Aim Assistance
    2715839340, // Recoil Direction
    3555269338, // Zoom
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

  static const socketCategoryIntrinsicPerkHashes = [
    3154740035, //armor perks
    3956125808, //weapon perks
  ];

  static const List<int> socketCategoryTierHashes = [
    760375309, // armor tier
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

  static const List<int> socketCategoryCosmeticModHashes = [
    1926152773, // armor cosmetics
    2048875504, // weapon mods
  ];

  static IconData getClassIcon(DestinyClass type) {
    switch (type) {
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
        return Color.fromARGB(255, 116, 247, 146);
      case DestinyAmmunitionType.Heavy:
        return Color.fromARGB(255, 179, 127, 251);

      default:
        return Colors.white;
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

  static IconData getEnergyTypeIcon(DestinyEnergyType type) {
    switch (type) {
      case DestinyEnergyType.Arc:
        return LittleLightIcons.damage_arc;
      case DestinyEnergyType.Thermal:
        return LittleLightIcons.damage_solar;
      case DestinyEnergyType.Void:
        return LittleLightIcons.damage_void;

      default:
        return null;
    }
  }

  static Color getDamageTypeColor(DamageType damageType) {
    switch (damageType) {
      case DamageType.Arc:
        return Color.fromARGB(255, 118, 186, 230);
      case DamageType.Thermal:
        return Color.fromARGB(255, 243, 98, 39);
      case DamageType.Void:
        return Color.fromARGB(255, 64, 34, 101);
      case DamageType.Stasis:
        return Color.fromARGB(255, 77, 136, 255);

      default:
        return Colors.white;
    }
  }

  static Color getEnergyTypeColor(DestinyEnergyType energyType) {
    switch (energyType) {
      case DestinyEnergyType.Arc:
        return Color.fromARGB(255, 118, 186, 230);
      case DestinyEnergyType.Thermal:
        return Color.fromARGB(255, 243, 98, 39);
      case DestinyEnergyType.Void:
        return Color.fromARGB(255, 64, 34, 101);

      default:
        return Colors.blueGrey.shade700;
    }
  }

  static Color getEnergyTypeLightColor(DestinyEnergyType damageType) {
    switch (damageType) {
      case DestinyEnergyType.Arc:
        return Color.fromARGB(255, 130, 200, 253);
      case DestinyEnergyType.Thermal:
        return Color.fromARGB(255, 255, 156, 74);
      case DestinyEnergyType.Void:
        return Color.fromARGB(255, 177, 120, 248);

      default:
        return Colors.grey.shade300;
    }
  }

  static int getEnergyTypeCostHash(DestinyEnergyType damageType) {
    switch (damageType) {
      case DestinyEnergyType.Arc:
        return 3779394102;
      case DestinyEnergyType.Thermal:
        return 3344745325;
      case DestinyEnergyType.Void:
        return 2399985800;

      default:
        return null;
    }
  }

  static Color getDamageTypeTextColor(DamageType damageType) {
    switch (damageType) {
      case DamageType.Arc:
        return Color.fromARGB(255, 130, 200, 253);
      case DamageType.Thermal:
        return Color.fromARGB(255, 255, 156, 74);
      case DamageType.Void:
        return Color.fromARGB(255, 177, 120, 248);
      case DamageType.Stasis:
        return Color.fromARGB(255, 77, 136, 255);
      default:
        return Colors.white;
    }
  }

  static Color getTierColor(TierType tierType) {
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

      case TierType.Unknown:
      case TierType.Currency:
      case TierType.ProtectedInvalidEnumValue:
        return Color.fromARGB(255, 195, 188, 180);
    }
    return null;
  }

  static Color getTierTextColor(TierType tierType) {
    switch (tierType) {
      case TierType.Basic:
      case TierType.Unknown:
      case TierType.Currency:
      case TierType.ProtectedInvalidEnumValue:
        return Colors.grey.shade800;

      default:
        return Colors.white;
    }
  }

  static String getSubclassImagePath(
      DestinyClass classType, DamageType damageType, String subclassPath) {
    String path = "assets/subclasses/";
    switch (classType) {
      case DestinyClass.Titan:
        path += "titan";
        break;
      case DestinyClass.Hunter:
        path += "hunter";
        break;
      case DestinyClass.Warlock:
        path += "warlock";
        break;

      default:
        return null;
    }

    switch (damageType) {
      case DamageType.Arc:
        path += "_arc";
        break;
      case DamageType.Thermal:
        path += "_solar";
        break;
      case DamageType.Void:
        path += "_void";
        break;
      case DamageType.Stasis:
        path += "_stasis";
        break;
      default:
        return null;
    }

    switch (subclassPath?.toLowerCase()) {
      case "firstpath":
      case "secondpath":
        break;
      case "thirdpath":
        path += "_alt";
        break;
      default:
        break;
    }

    return path + ".webp";
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
