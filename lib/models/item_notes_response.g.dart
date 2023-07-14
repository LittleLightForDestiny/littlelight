// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_notes_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotesResponse _$NotesResponseFromJson(Map<String, dynamic> json) =>
    NotesResponse(
      notes:
          (json['notes'] as List<dynamic>?)?.map(ItemNotes.fromJson).toList(),
      tags:
          (json['tags'] as List<dynamic>?)?.map(ItemNotesTag.fromJson).toList(),
    );

Map<String, dynamic> _$NotesResponseToJson(NotesResponse instance) =>
    <String, dynamic>{
      'notes': instance.notes,
      'tags': instance.tags,
    };
