// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_notes_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemNotesTag _$ItemNotesTagFromJson(Map<String, dynamic> json) => ItemNotesTag(
      custom: json['custom'] as bool? ?? false,
      tagId: json['tagId'] as String?,
      name: json['name'] as String? ?? "",
      backgroundColorHex: json['backgroundColorHex'] as String? ?? "#00000000",
      foregroundColorHex: json['foregroundColorHex'] as String? ?? "#FFFFFFFF",
      defaultTagType:
          $enumDecodeNullable(_$DefaultTagTypeEnumMap, json['defaultTagType']),
      icon: $enumDecodeNullable(_$ItemTagIconEnumMap, json['icon']) ??
          ItemTagIcon.Star,
    );

Map<String, dynamic> _$ItemNotesTagToJson(ItemNotesTag instance) =>
    <String, dynamic>{
      'custom': instance.custom,
      'tagId': instance.tagId,
      'name': instance.name,
      'backgroundColorHex': instance.backgroundColorHex,
      'foregroundColorHex': instance.foregroundColorHex,
      'icon': _$ItemTagIconEnumMap[instance.icon]!,
      'defaultTagType': _$DefaultTagTypeEnumMap[instance.defaultTagType],
    };

const _$DefaultTagTypeEnumMap = {
  DefaultTagType.Favorite: 'Favorite',
  DefaultTagType.Trash: 'Trash',
  DefaultTagType.Infuse: 'Infuse',
};

const _$ItemTagIconEnumMap = {
  ItemTagIcon.Heart: 'Heart',
  ItemTagIcon.Star: 'Star',
  ItemTagIcon.Infuse: 'Infuse',
  ItemTagIcon.Resources: 'Resources',
  ItemTagIcon.Trash: 'Trash',
  ItemTagIcon.ThumbsUp: 'ThumbsUp',
  ItemTagIcon.ThumbsDown: 'ThumbsDown',
  ItemTagIcon.Vanguard: 'Vanguard',
  ItemTagIcon.Vanguard2: 'Vanguard2',
  ItemTagIcon.Crucible: 'Crucible',
  ItemTagIcon.Crucible2: 'Crucible2',
  ItemTagIcon.Gambit: 'Gambit',
  ItemTagIcon.Raid: 'Raid',
  ItemTagIcon.IronBanner: 'IronBanner',
  ItemTagIcon.Osiris: 'Osiris',
  ItemTagIcon.Titan: 'Titan',
  ItemTagIcon.Hunter: 'Hunter',
  ItemTagIcon.Warlock: 'Warlock',
  ItemTagIcon.Kinetic: 'Kinetic',
  ItemTagIcon.Arc: 'Arc',
  ItemTagIcon.Thermal: 'Thermal',
  ItemTagIcon.Void: 'Void',
  ItemTagIcon.Pierce: 'Pierce',
  ItemTagIcon.Overload: 'Overload',
  ItemTagIcon.Stagger: 'Stagger',
  ItemTagIcon.Mobility: 'Mobility',
  ItemTagIcon.Resilience: 'Resilience',
  ItemTagIcon.Recovery: 'Recovery',
  ItemTagIcon.Intellect: 'Intellect',
  ItemTagIcon.Discipline: 'Discipline',
  ItemTagIcon.Strength: 'Strength',
  ItemTagIcon.Sentry: 'Sentry',
  ItemTagIcon.Reaper: 'Reaper',
  ItemTagIcon.Invader: 'Invader',
  ItemTagIcon.Collector: 'Collector',
  ItemTagIcon.BlockerSmall: 'BlockerSmall',
  ItemTagIcon.BlockerMedium: 'BlockerMedium',
  ItemTagIcon.BlockerLarge: 'BlockerLarge',
  ItemTagIcon.BlockerGiant: 'BlockerGiant',
};
