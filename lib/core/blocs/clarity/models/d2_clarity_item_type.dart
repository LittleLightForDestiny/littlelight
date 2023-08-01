import 'package:json_annotation/json_annotation.dart';

enum ClarityItemType {
  @JsonValue('Armor Mod General')
  ArmorModGeneral,
  @JsonValue('Armor Trait Exotic')
  ArmorTraitExotic,
  @JsonValue('Weapon Trait')
  WeaponTrait,
  @JsonValue('Weapon Trait Enhanced')
  WeaponTraitEnhanced,
  @JsonValue('Weapon Trait Origin')
  WeaponTraitOrigin,
  @JsonValue('Weapon Trait Exotic')
  WeaponTraitExotic,
  @JsonValue('Weapon Mod')
  WeaponMod,
  @JsonValue('Weapon Perk')
  WeaponPerk,
  @JsonValue('Weapon Frame')
  WeaponFrame,
  @JsonValue('Weapon Catalyst Exotic')
  WeaponCatalystExotic,
  @JsonValue('Unknown')
  Unknown,
}
