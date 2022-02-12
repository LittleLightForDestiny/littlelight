// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'item_notes_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotesResponse _$NotesResponseFromJson(Map<String, dynamic> json) => NotesResponse(
      notes: (json['notes'] as List<dynamic>?)?.map((e) => ItemNotes.fromJson(e)).toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => ItemNotesTag.fromJson(e)).toList(),
    );

Map<String, dynamic> _$NotesResponseToJson(NotesResponse instance) => <String, dynamic>{
      'notes': instance.notes,
      'tags': instance.tags,
    };
