// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_notes_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemNotesTag _$ItemNotesTagFromJson(Map<String, dynamic> json) {
  return ItemNotesTag(
    custom: json['custom'] as bool,
    tagId: json['tagId'] as String,
    name: json['name'] as String,
    backgroundColorHex: json['backgroundColorHex'] as String,
    foregroundColorHex: json['foregroundColorHex'] as String,
    icon: _$enumDecodeNullable(_$ItemTagIconEnumMap, json['icon']),
  );
}

Map<String, dynamic> _$ItemNotesTagToJson(ItemNotesTag instance) =>
    <String, dynamic>{
      'custom': instance.custom,
      'tagId': instance.tagId,
      'name': instance.name,
      'backgroundColorHex': instance.backgroundColorHex,
      'foregroundColorHex': instance.foregroundColorHex,
      'icon': _$ItemTagIconEnumMap[instance.icon],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$ItemTagIconEnumMap = {
  ItemTagIcon.Heart: 'Heart',
  ItemTagIcon.Crucible: 'Crucible',
  ItemTagIcon.Vanguard: 'Vanguard',
  ItemTagIcon.Trash: 'Trash',
};
