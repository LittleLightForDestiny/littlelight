//@dart=2.12

import 'package:json_annotation/json_annotation.dart';

import 'item_notes.dart';
import 'item_notes_tag.dart';

@JsonSerializable()
class NotesResponse {
  List<ItemNotes> notes;
  List<ItemNotesTag> tags;

  NotesResponse({List<ItemNotes>? notes, List<ItemNotesTag>? tags}):
    this.notes = notes ?? [],
    this.tags = tags ?? [];
}