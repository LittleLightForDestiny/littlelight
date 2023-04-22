import 'package:json_annotation/json_annotation.dart';

part 'item_notes.g.dart';

@JsonSerializable()
class ItemNotes {
  static String generateId(int itemHash, String? instanceId) => "${itemHash}_$instanceId";

  String? itemInstanceId;
  int itemHash;

  String? customName;
  String? notes;

  @JsonKey(defaultValue: <String>{})
  Set<String> tags;

  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  ItemNotes({
    this.itemInstanceId,
    required this.itemHash,
    this.customName,
    this.notes,
    required this.tags,
    required this.updatedAt,
  });

  String get uniqueId {
    return generateId(itemHash, itemInstanceId);
  }

  factory ItemNotes.fromScratch({
    required int itemHash,
    String? itemInstanceId,
  }) {
    return ItemNotes(updatedAt: DateTime.now(), itemHash: itemHash, tags: <String>{}, itemInstanceId: itemInstanceId);
  }

  factory ItemNotes.fromJson(dynamic json) {
    return _$ItemNotesFromJson(json);
  }

  dynamic toJson() {
    return _$ItemNotesToJson(this);
  }
}
