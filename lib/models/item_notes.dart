import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:uuid/uuid.dart';

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

  factory ItemNotes.fromScratch() {
    return ItemNotes(updatedAt: DateTime.now());
  }

  factory ItemNotes.copy(ItemNotes original) {
    return ItemNotes(
      itemInstanceId: original.itemInstanceId,
      itemHash: original.itemHash,
      customName: original.customName,
      notes: original.notes,
      tags: original.tags,
      updatedAt: original.updatedAt,
    );
  }

  factory ItemNotes.fromJson(dynamic json) {
    return _$ItemNotesFromJson(json);
  }

  dynamic toJson() {
    return _$ItemNotesToJson(this);
  }
}
