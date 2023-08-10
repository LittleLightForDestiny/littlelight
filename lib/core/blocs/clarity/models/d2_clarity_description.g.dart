// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'd2_clarity_description.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClarityDescription _$ClarityDescriptionFromJson(Map<String, dynamic> json) =>
    ClarityDescription(
      linesContent: (json['linesContent'] as List<dynamic>?)
          ?.map((e) => ClarityLineContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      classNames: (json['classNames'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ClarityClassNamesEnumMap, e,
              unknownValue: ClarityClassNames.Unknown))
          .toList(),
      table: (json['table'] as List<dynamic>?)
          ?.map((e) => ClarityTableRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFormula: json['isFormula'] as bool?,
      weaponTypes: (json['weaponTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ClarityWeaponTypeEnumMap, e,
              unknownValue: ClarityWeaponType.Unknown))
          .toList(),
    );

Map<String, dynamic> _$ClarityDescriptionToJson(ClarityDescription instance) =>
    <String, dynamic>{
      'linesContent': instance.linesContent,
      'table': instance.table,
      'isFormula': instance.isFormula,
      'classNames': instance.classNames
          ?.map((e) => _$ClarityClassNamesEnumMap[e]!)
          .toList(),
      'weaponTypes': instance.weaponTypes
          ?.map((e) => _$ClarityWeaponTypeEnumMap[e]!)
          .toList(),
    };

const _$ClarityClassNamesEnumMap = {
  ClarityClassNames.Spacer: 'spacer',
  ClarityClassNames.Pve: 'pve',
  ClarityClassNames.Pvp: 'pvp',
  ClarityClassNames.BreakSpaces: 'breakSpaces',
  ClarityClassNames.Background2: 'background_2',
  ClarityClassNames.Yellow: 'yellow',
  ClarityClassNames.Formula: 'formula',
  ClarityClassNames.Wide: 'wide',
  ClarityClassNames.Heavy: 'heavy',
  ClarityClassNames.Primary: 'primary',
  ClarityClassNames.Special: 'special',
  ClarityClassNames.Green: 'green',
  ClarityClassNames.EnhancedArrow: 'enhancedArrow',
  ClarityClassNames.Title: 'title',
  ClarityClassNames.Solar: 'solar',
  ClarityClassNames.Strand: 'strand',
  ClarityClassNames.Arc: 'arc',
  ClarityClassNames.Void: 'void',
  ClarityClassNames.Stasis: 'stasis',
  ClarityClassNames.Link: 'link',
  ClarityClassNames.Overload: 'overload',
  ClarityClassNames.Barrier: 'barrier',
  ClarityClassNames.Hunter: 'hunter',
  ClarityClassNames.Titan: 'titan',
  ClarityClassNames.Warlock: 'warlock',
  ClarityClassNames.Bold: 'bold',
  ClarityClassNames.Blue: 'blue',
  ClarityClassNames.Unstoppable: 'unstoppable',
  ClarityClassNames.Background: 'background',
  ClarityClassNames.Center: 'center',
  ClarityClassNames.Unknown: 'Unknown',
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
