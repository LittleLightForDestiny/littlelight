// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'd2_clarity_line_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClarityLineContent _$ClarityLineContentFromJson(Map<String, dynamic> json) =>
    ClarityLineContent(
      title: (json['title'] as List<dynamic>?)
          ?.map(ClarityDescription.fromJson)
          .toList(),
      text: json['text'] as String?,
      classNames: (json['classNames'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ClarityClassNamesEnumMap, e,
              unknownValue: ClarityClassNames.Unknown))
          .toList(),
      formula:
          $enumDecodeNullable(_$ClarityFormulaTypeEnumMap, json['formula']),
      link: json['link'] as String?,
    );

Map<String, dynamic> _$ClarityLineContentToJson(ClarityLineContent instance) =>
    <String, dynamic>{
      'title': instance.title,
      'text': instance.text,
      'formula': _$ClarityFormulaTypeEnumMap[instance.formula],
      'link': instance.link,
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

const _$ClarityFormulaTypeEnumMap = {
  ClarityFormulaType.Ready0: 'ready_0',
  ClarityFormulaType.Stow0: 'stow_0',
  ClarityFormulaType.Range0: 'range_0',
  ClarityFormulaType.Reload0: 'reload_0',
  ClarityFormulaType.Reload1: 'reload_1',
  ClarityFormulaType.Unknown: 'Unknown',
};
