import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item_notes.g.dart';

@JsonSerializable()
class ItemNotes {
  String itemInstanceId;
  int itemHash;

  String customName;
  String notes;

  Set<String> tags;

  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  ItemNotes(
      {this.itemInstanceId,
      this.itemHash,
      this.customName,
      this.notes,
      this.tags,
      @required this.updatedAt});

  factory ItemNotes.fromScratch({int itemHash, String itemInstanceId}) {
    return ItemNotes(
        updatedAt: DateTime.now(),
        itemHash: itemHash,
        tags: Set(),
        itemInstanceId: itemInstanceId);
  }

  factory ItemNotes.fromJson(dynamic json) {
    return _$ItemNotesFromJson(json);
  }

  dynamic toJson() {
    return _$ItemNotesToJson(this);
  }
}
