// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'd2_clarity_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClarityStat _$ClarityStatFromJson(Map<String, dynamic> json) => ClarityStat(
      active: json['active'],
      passive: json['passive'],
      weaponTypes: (json['weaponTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ClarityWeaponTypeEnumMap, e,
              unknownValue: ClarityWeaponType.Unknown))
          .toList(),
    );

Map<String, dynamic> _$ClarityStatToJson(ClarityStat instance) =>
    <String, dynamic>{
      'active': instance.active,
      'passive': instance.passive,
      'weaponTypes': instance.weaponTypes
          ?.map((e) => _$ClarityWeaponTypeEnumMap[e]!)
          .toList(),
    };

const _$ClarityWeaponTypeEnumMap = {
  ClarityWeaponType.Fusion: 'Fusion',
  ClarityWeaponType.AutoRifle: 'AR',
  ClarityWeaponType.MachineGun: 'LMG',
  ClarityWeaponType.PulseRifle: 'Pulse',
  ClarityWeaponType.TraceRifle: 'Trace',
  ClarityWeaponType.LinearFusionRifle: 'LFR',
  ClarityWeaponType.Bow: 'Bow',
  ClarityWeaponType.Glaive: 'Glaive',
  ClarityWeaponType.HandCannon: 'HC',
  ClarityWeaponType.ScoutRifle: 'Scout',
  ClarityWeaponType.GrenadeLauncher: 'GL',
  ClarityWeaponType.HeavyGrenadeLauncher: 'Heavy GL',
  ClarityWeaponType.RocketLauncher: 'Rocket',
  ClarityWeaponType.Shotgun: 'Shotgun',
  ClarityWeaponType.Sidearm: 'Sidearm',
  ClarityWeaponType.SubMachineGun: 'SMG',
  ClarityWeaponType.SniperRifle: 'Sniper',
  ClarityWeaponType.Sword: 'Sword',
  ClarityWeaponType.Grenade: 'Grenade',
  ClarityWeaponType.Melee: 'Melee',
  ClarityWeaponType.Super: 'Super',
  ClarityWeaponType.Unknown: 'Unknown',
};
