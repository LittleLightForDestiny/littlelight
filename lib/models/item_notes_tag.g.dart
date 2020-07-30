// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_notes_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemNotesTag _$ItemNotesTagFromJson(Map<String, dynamic> json) {
  return ItemNotesTag(
    custom: json['custom'] as bool,
    tagId: json['tagId'] as String,
    customName: json['customName'] as String,
    customColorHex: json['customColorHex'] as String,
    customIconName: json['customIconName'] as String,
  );
}

Map<String, dynamic> _$ItemNotesTagToJson(ItemNotesTag instance) =>
    <String, dynamic>{
      'custom': instance.custom,
      'tagId': instance.tagId,
      'customName': instance.customName,
      'customColorHex': instance.customColorHex,
      'customIconName': instance.customIconName,
    };
