// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'd2_clarity_table_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClarityTableRow _$ClarityTableRowFromJson(Map<String, dynamic> json) =>
    ClarityTableRow(
      classNames: (json['classNames'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ClarityClassNamesEnumMap, e,
              unknownValue: ClarityClassNames.Unknown))
          .toList(),
      rowContent: (json['rowContent'] as List<dynamic>?)
          ?.map((e) => ClarityTableCell.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClarityTableRowToJson(ClarityTableRow instance) =>
    <String, dynamic>{
      'rowContent': instance.rowContent,
      'classNames': instance.classNames
          ?.map((e) => _$ClarityClassNamesEnumMap[e]!)
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
