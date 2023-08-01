// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'd2_clarity_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClarityItem _$ClarityItemFromJson(Map<String, dynamic> json) => ClarityItem(
      hash: json['hash'] as int?,
      itemHash: json['itemHash'] as int?,
      name: json['name'] as String?,
      itemName: json['itemName'] as String?,
      lastUpload: _dateFromJson(json['lastUpload'] as int),
      type: $enumDecodeNullable(_$ClarityItemTypeEnumMap, json['type']),
      uploadedBy: json['uploadedBy'] as String?,
      descriptions: (json['descriptions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, (e as List<dynamic>).map(ClarityDescription.fromJson).toList()),
      ),
      stats: (json['stats'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            $enumDecode(_$ClarityStatTypeEnumMap, k),
            (e as List<dynamic>)
                .map((e) => ClarityStat.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
    );

Map<String, dynamic> _$ClarityItemToJson(ClarityItem instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'itemHash': instance.itemHash,
      'name': instance.name,
      'itemName': instance.itemName,
      'type': _$ClarityItemTypeEnumMap[instance.type],
      'lastUpload': _dateToJson(instance.lastUpload),
      'uploadedBy': instance.uploadedBy,
      'descriptions': instance.descriptions,
      'stats': instance.stats
          ?.map((k, e) => MapEntry(_$ClarityStatTypeEnumMap[k]!, e)),
    };

const _$ClarityItemTypeEnumMap = {
  ClarityItemType.ArmorModGeneral: 'Armor Mod General',
  ClarityItemType.ArmorTraitExotic: 'Armor Trait Exotic',
  ClarityItemType.WeaponTrait: 'Weapon Trait',
  ClarityItemType.WeaponTraitEnhanced: 'Weapon Trait Enhanced',
  ClarityItemType.WeaponTraitOrigin: 'Weapon Trait Origin',
  ClarityItemType.WeaponTraitExotic: 'Weapon Trait Exotic',
  ClarityItemType.WeaponMod: 'Weapon Mod',
  ClarityItemType.WeaponPerk: 'Weapon Perk',
  ClarityItemType.WeaponFrame: 'Weapon Frame',
  ClarityItemType.WeaponCatalystExotic: 'Weapon Catalyst Exotic',
  ClarityItemType.Unknown: 'Unknown',
};

const _$ClarityStatTypeEnumMap = {
  ClarityStatType.Handling: 'Handling',
  ClarityStatType.PVEDamage: 'PVE Damage',
  ClarityStatType.PVPDamage: 'PVP Damage',
  ClarityStatType.AimAssist: 'Aim Assist',
  ClarityStatType.Range: 'Range',
  ClarityStatType.Reload: 'Reload',
  ClarityStatType.ChargeDraw: 'Charge Draw',
  ClarityStatType.Airborne: 'Airborne',
  ClarityStatType.Stability: 'Stability',
  ClarityStatType.GuardEndurance: 'Guard Endurance',
  ClarityStatType.Stow: 'Stow',
  ClarityStatType.AimDownSight: 'ADS',
  ClarityStatType.GuardChargeRate: 'Guard Charge Rate',
  ClarityStatType.Ready: 'Ready',
  ClarityStatType.Damage: 'Damage',
  ClarityStatType.GuardResistance: 'Guard Resistance',
  ClarityStatType.FiringDelay: 'Firing Delay',
  ClarityStatType.GuardEfficiency: 'Guard Efficiency',
  ClarityStatType.Zoom: 'Zoom',
  ClarityStatType.BlastRadius: 'Blast Radius',
};
