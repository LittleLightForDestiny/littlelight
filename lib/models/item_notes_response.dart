import 'package:json_annotation/json_annotation.dart';

import 'item_notes.dart';
import 'item_notes_tag.dart';

part 'item_notes_response.g.dart';

@JsonSerializable()
class NotesResponse {
  List<ItemNotes> notes;
  List<ItemNotesTag> tags;

  NotesResponse({List<ItemNotes>? notes, List<ItemNotesTag>? tags})
      : this.notes = notes ?? [],
        this.tags = tags ?? [];

  factory NotesResponse.fromJson(Map<String, dynamic> json) => _$NotesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotesResponseToJson(this);
}
