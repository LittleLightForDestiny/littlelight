import 'package:bungie_api/enums/damage_type_enum.dart';

enum RunePosition { Top, Left, Right }

enum RuneColor { Purple, Red, Green, Blue }
enum Rune {
  AnyPurple,
  Joy,
  Beast,
  Jubilation,
  AnyRed,
  Cunning,
  Gluttony,
  Ambition,
  AnyGreen,
  War,
  Desire,
  Pride,
  AnyBlue,
  Pleasure,
  Excess,
  Wealth,
}

enum ArmorIntrinsics { Mobility, Recovery, Resilience }

enum WeaponMasterwork { Handling, Reload, Range, Stability }

class RuneInfo {
  final RuneColor color;
  final int itemHash;
  final ArmorIntrinsics armorPerk;
  
  const RuneInfo({
    this.color,
    this.itemHash,
    this.armorPerk,
  });

  int get armorMasterworkDamageType{
    switch(color){
      case RuneColor.Purple:
        return DamageType.Arc;
      case RuneColor.Red:
        return DamageType.Thermal;
      case RuneColor.Green:
        return DamageType.Void;
      case RuneColor.Blue:
        return DamageType.Thermal;
    }
    return null;
  }

  WeaponMasterwork get weaponMasterwork{
    switch(color){
      case RuneColor.Purple:
        return WeaponMasterwork.Handling;
      case RuneColor.Green:
        return WeaponMasterwork.Range;
      case RuneColor.Red:
        return WeaponMasterwork.Reload;
      case RuneColor.Blue:
        return WeaponMasterwork.Stability;
    }
    return null;
  }
}

const Map<Rune, RuneInfo> _runeSpecs = const {
  Rune.AnyPurple: RuneInfo(color: RuneColor.Purple),
  Rune.Joy: RuneInfo(
      color: RuneColor.Purple,
      itemHash: 2149082453,
      armorPerk: ArmorIntrinsics.Mobility),
  Rune.Beast: RuneInfo(
      color: RuneColor.Purple,
      itemHash: 2149082452,
      armorPerk: ArmorIntrinsics.Recovery),
  Rune.Jubilation: RuneInfo(
      color: RuneColor.Purple,
      itemHash: 2149082455,
      armorPerk: ArmorIntrinsics.Resilience),
  Rune.AnyRed: RuneInfo(color: RuneColor.Red),
  Rune.Cunning: RuneInfo(
      color: RuneColor.Red,
      itemHash: 2149082454,
      armorPerk: ArmorIntrinsics.Mobility),
  Rune.Gluttony: RuneInfo(
      color: RuneColor.Red,
      itemHash: 2149082449,
      armorPerk: ArmorIntrinsics.Recovery),
  Rune.Ambition: RuneInfo(
      color: RuneColor.Red,
      itemHash: 2149082448,
      armorPerk: ArmorIntrinsics.Resilience),
  Rune.AnyGreen: RuneInfo(color: RuneColor.Green),
  Rune.War: RuneInfo(
      color: RuneColor.Green,
      itemHash: 2149082451,
      armorPerk: ArmorIntrinsics.Mobility),
  Rune.Desire: RuneInfo(
      color: RuneColor.Green,
      itemHash: 2149082450,
      armorPerk: ArmorIntrinsics.Recovery),
  Rune.Pride: RuneInfo(
      color: RuneColor.Green,
      itemHash: 2149082461,
      armorPerk: ArmorIntrinsics.Resilience),
  Rune.AnyBlue: RuneInfo(color: RuneColor.Blue),
  Rune.Pleasure: RuneInfo(
      color: RuneColor.Blue,
      itemHash: 2149082460,
      armorPerk: ArmorIntrinsics.Mobility),
  Rune.Excess: RuneInfo(
      color: RuneColor.Blue,
      itemHash: 4201087756,
      armorPerk: ArmorIntrinsics.Recovery),
  Rune.Wealth: RuneInfo(
      color: RuneColor.Blue,
      itemHash: 4201087757,
      armorPerk: ArmorIntrinsics.Resilience),
};

const Map<RuneColor, List<Rune>> _runesByColor = {
  RuneColor.Purple: [Rune.Joy, Rune.Beast, Rune.Jubilation],
  RuneColor.Red: [
    Rune.Cunning,
    Rune.Gluttony,
    Rune.Ambition,
  ],
  RuneColor.Green: [
    Rune.War,
    Rune.Desire,
    Rune.Pride,
  ],
  RuneColor.Blue: [
    Rune.Pleasure,
    Rune.Excess,
    Rune.Wealth,
  ],
};

class ChaliceRecipe {
  final Rune _top;
  final Rune _left;
  ChaliceRecipe(this._top, this._left);
  factory ChaliceRecipe.get(int hash) => _recipes[hash];

  RuneInfo get top {
    return _runeSpecs[_top];
  }

  List<RuneInfo> get left {
    if ([
      Rune.War,
      Rune.Cunning,
      Rune.Pleasure,
      Rune.Gluttony,
      Rune.Joy,
    ].contains(_top)) {
      var _spec = _runeSpecs[_left];
      return _runesByColor[_spec.color].map((r)=>_runeSpecs[r]).toList();
    }
    return [_runeSpecs[_left]];
  }

  List<RuneInfo> get right {
    return [Rune.AnyPurple, Rune.AnyRed, Rune.AnyGreen, Rune.AnyBlue]
        .map((r) => _runeSpecs[r])
        .toList();
  }
}

class _ArmorRecipe {
  final ChaliceRecipe helmet;
  final ChaliceRecipe gauntlets;
  final ChaliceRecipe chest;
  final ChaliceRecipe boots;
  final ChaliceRecipe classItem;

  const _ArmorRecipe(
      {this.helmet, this.gauntlets, this.chest, this.boots, this.classItem});
}

final _tangledWebArmor = _ArmorRecipe(
    helmet: ChaliceRecipe(Rune.War, Rune.AnyPurple),
    gauntlets: ChaliceRecipe(Rune.Cunning, Rune.AnyPurple),
    chest: ChaliceRecipe(Rune.Pleasure, Rune.AnyPurple),
    boots: ChaliceRecipe(Rune.Gluttony, Rune.AnyPurple),
    classItem: ChaliceRecipe(Rune.Joy, Rune.AnyPurple));

final _exodusDownArmor = _ArmorRecipe(
    helmet: ChaliceRecipe(Rune.War, Rune.AnyRed),
    gauntlets: ChaliceRecipe(Rune.Cunning, Rune.AnyRed),
    chest: ChaliceRecipe(Rune.Pleasure, Rune.AnyRed),
    boots: ChaliceRecipe(Rune.Gluttony, Rune.AnyRed),
    classItem: ChaliceRecipe(Rune.Joy, Rune.AnyRed));

final _reverieDawnArmor = _ArmorRecipe(
    helmet: ChaliceRecipe(Rune.War, Rune.AnyGreen),
    gauntlets: ChaliceRecipe(Rune.Cunning, Rune.AnyGreen),
    chest: ChaliceRecipe(Rune.Pleasure, Rune.AnyGreen),
    boots: ChaliceRecipe(Rune.Gluttony, Rune.AnyGreen),
    classItem: ChaliceRecipe(Rune.Joy, Rune.AnyGreen));

final _opulentArmor = _ArmorRecipe(
    helmet: ChaliceRecipe(Rune.War, Rune.AnyBlue),
    gauntlets: ChaliceRecipe(Rune.Cunning, Rune.AnyBlue),
    chest: ChaliceRecipe(Rune.Pleasure, Rune.AnyBlue),
    boots: ChaliceRecipe(Rune.Gluttony, Rune.AnyBlue),
    classItem: ChaliceRecipe(Rune.Joy, Rune.AnyBlue));

final Map<int, ChaliceRecipe> _recipes = {
// Tangled Web - Titan armor,
  2982412348: _tangledWebArmor.helmet, // Tangled Web Helm,
  42219189: _tangledWebArmor.gauntlets, // Tangled Web Gauntlets,
  2562470699: _tangledWebArmor.chest, // Tangled Web Plate,
  1618341271: _tangledWebArmor.boots, // Tangled Web Greaves,
  919186882: _tangledWebArmor.classItem, // Tangled Web Mark

// Tangled Web - Hunter armor
  4261835528: _tangledWebArmor.helmet, // Tangled Web Mask,
  3609169817: _tangledWebArmor.gauntlets, // Tangled Web Grips,
  2648545535: _tangledWebArmor.chest, // Tangled Web Vest,
  2206284939: _tangledWebArmor.boots, // Tangled Web Strides,
  25091086: _tangledWebArmor.classItem, // Tangled Web Cloak

// Tangled Web - Warlock armor,
  1664085089: _tangledWebArmor.helmet, // Tangled Web Hood,
  2502004600: _tangledWebArmor.gauntlets, // Tangled Web Gloves,
  1034149520: _tangledWebArmor.chest, // Tangled Web Robes,
  537272242: _tangledWebArmor.boots, // Tangled Web Boots,
  4256272077: _tangledWebArmor.classItem, // Tangled Web Bond

  // Exodus Down - Titan armor
  582151075: _exodusDownArmor.helmet, // Exodus Down Helm,
  1678216306: _exodusDownArmor.gauntlets, // Exodus Down Gauntlets,
  1156448694: _exodusDownArmor.chest, // Exodus Down,
  2079454604: _exodusDownArmor.boots, // Exodus Down Greaves,
  527652447: _exodusDownArmor.classItem, // Exodus Down Mark

  // Exodus Down - Hunter armor
  2172333833: _exodusDownArmor.helmet, // Exodus Down Mask,
  3875829376: _exodusDownArmor.gauntlets, // Exodus Down Grips,
  126418248: _exodusDownArmor.chest, // Exodus Down Vest,
  2953649850: _exodusDownArmor.boots, // Exodus Down Strides,
  2252973221: _exodusDownArmor.classItem, // Exodus Down Cloak

  // Exodus Down - Warlock armor
  2731698402: _exodusDownArmor.helmet, // Exodus Down Hood
  2029766091: _exodusDownArmor.gauntlets, // Exodus Down Gloves
  2218838661: _exodusDownArmor.chest, // Exodus Down Robes
  3545981149: _exodusDownArmor.boots, // Exodus Down Boots
  874856664: _exodusDownArmor.classItem, // Exodus Down Bond

// Reverie Dawn - Titan armor
  4097166900: _reverieDawnArmor.helmet, // Reverie Dawn Helm
  2503434573: _reverieDawnArmor.gauntlets, // Reverie Dawn Gauntlets
  4070309619: _reverieDawnArmor.chest, // Reverie Dawn Plate
  3174233615: _reverieDawnArmor.boots, // Reverie Dawn Greaves
  1980768298: _reverieDawnArmor.classItem, // Reverie Dawn Mark

// Reverie Dawn - Hunter armor
  2824453288: _reverieDawnArmor.helmet, // Reverie Dawn Casque
  1705856569: _reverieDawnArmor.gauntlets, // Reverie Dawn Grasps
  1593474975: _reverieDawnArmor.chest, // Reverie Dawn Hauberk
  344548395: _reverieDawnArmor.boots, // Reverie Dawn Strides
  3306564654: _reverieDawnArmor.classItem, // Reverie Dawn Cloak

// Reverie Dawn - Warlock armor
  185695659: _reverieDawnArmor.helmet, // Reverie Dawn Hood
  2761343386: _reverieDawnArmor.gauntlets, // Reverie Dawn Gloves
  2859583726: _reverieDawnArmor.chest, // Reverie Dawn Tabard
  188778964: _reverieDawnArmor.boots, // Reverie Dawn Boots
  3602032567: _reverieDawnArmor.classItem, // Reverie Dawn Bond

  // Opulent - Titan armor
  1420117606: _opulentArmor.helmet, // Opulent Duelist Helm
  392500791: _opulentArmor.gauntlets, // Opulent Duelist Gauntlets
  2856582785: _opulentArmor.chest, // Opulent Duelist Plate
  1776578009: _opulentArmor.boots, // Opulent Duelist Greaves
  4105225180: _opulentArmor.classItem, // Opulent Duelist Mark

// Opulent - Hunter armor
  906236408: _opulentArmor.helmet, // Opulent Stalker Mask
  1370039881: _opulentArmor.gauntlets, // Opulent Stalker Grips
  3759327055: _opulentArmor.chest, // Opulent Stalker Vest
  1661981723: _opulentArmor.boots, // Opulent Stalker Strides
  1135872734: _opulentArmor.classItem, // Opulent Stalker Cloak

// Opulent - Warlock armor
  831222279: _opulentArmor.helmet, // Opulent Scholar Hood
  3072788622: _opulentArmor.gauntlets, // Opulent Scholar Gloves
  2026757026: _opulentArmor.chest, // Opulent Scholar Robes
  1285460104: _opulentArmor.boots, // Opulent Scholar Boots
  1250649843: _opulentArmor.classItem, // Opulent Scholar Bond

//SMGs
  174192097: ChaliceRecipe(Rune.Beast, Rune.AnyPurple), // CALUS Mini-Tool
  2681395357: ChaliceRecipe(Rune.Beast, Rune.AnyRed), // Trackless Waste
  105567493: ChaliceRecipe(Rune.Beast, Rune.AnyGreen), // Hard Truths
  2105827099: ChaliceRecipe(Rune.Beast, Rune.AnyBlue), // Bad Reputation

//Snipers
  3297863558: ChaliceRecipe(Rune.Jubilation, Rune.AnyPurple), // Twilight Oath
  4190932264: ChaliceRecipe(Rune.Jubilation, Rune.AnyRed), // Beloved
  1684914716: ChaliceRecipe(Rune.Jubilation, Rune.AnyGreen), // Fate Cries Foul
  3100452337: ChaliceRecipe(Rune.Jubilation, Rune.AnyBlue), // Dreaded Venture

//Power Weapons
  991314988: ChaliceRecipe(Rune.Ambition, Rune.AnyPurple), // Bad Omens
  3776129137: ChaliceRecipe(Rune.Ambition, Rune.AnyRed), // Zenobia-D
  3740842661: ChaliceRecipe(Rune.Ambition, Rune.AnyGreen), // Sleepless
  1642384931: ChaliceRecipe(Rune.Ambition, Rune.AnyBlue), // Fixed Odds

//Hand Cannons
  4077196130: ChaliceRecipe(Rune.Desire, Rune.AnyPurple), // Trust
  2429822977: ChaliceRecipe(Rune.Desire, Rune.AnyRed), // Austringer
  334171687: ChaliceRecipe(Rune.Desire, Rune.AnyGreen), // Waking Vigil
  4211534763: ChaliceRecipe(Rune.Desire, Rune.AnyBlue), // Pribina-D

// Sidearms
  79075821: ChaliceRecipe(Rune.Pride, Rune.AnyPurple), // Drang (Baroque)
  2009277538: ChaliceRecipe(Rune.Pride, Rune.AnyRed), // The Last Dance
  3222518097: ChaliceRecipe(Rune.Pride, Rune.AnyGreen), // Anonymous Autumn
  1843044399: ChaliceRecipe(Rune.Pride, Rune.AnyBlue), // Smuggler's Word

// Fusion Rifles
  3027844940: ChaliceRecipe(Rune.Excess, Rune.AnyPurple), // Proelium FR3
  253196586: ChaliceRecipe(Rune.Excess, Rune.AnyRed), // Main Ingredient
  4124357815: ChaliceRecipe(Rune.Excess, Rune.AnyGreen), // The Epicurean
  3027844941: ChaliceRecipe(Rune.Excess, Rune.AnyBlue), // Erentil FR4

// Shotguns
  1327264046: ChaliceRecipe(Rune.Wealth, Rune.AnyPurple), // Badlander
  2217366863: ChaliceRecipe(Rune.Wealth, Rune.AnyRed), // Parcel of Stardust
  2919334548: ChaliceRecipe(Rune.Wealth, Rune.AnyGreen), // Imperial Decree
  636912560: ChaliceRecipe(Rune.Wealth, Rune.AnyBlue), // Dust Rock Blues
};
