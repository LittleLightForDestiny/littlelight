// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_notes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemNotes _$ItemNotesFromJson(Map<String, dynamic> json) {
  return ItemNotes(
    itemInstanceId: json['itemInstanceId'] as String,
    itemHash: json['itemHash'] as int,
    customName: json['customName'] as String,
    notes: json['notes'] as String,
    tags: (json['tags'] as List)?.map((e) => e as String)?.toSet(),
    updatedAt: json['updated_at'] == null
        ? null
        : DateTime.parse(json['updated_at'] as String),
  );
}

Map<String, dynamic> _$ItemNotesToJson(ItemNotes instance) => <String, dynamic>{
      'itemInstanceId': instance.itemInstanceId,
      'itemHash': instance.itemHash,
      'customName': instance.customName,
      'notes': instance.notes,
      'tags': instance.tags?.toList(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
