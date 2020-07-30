import 'package:json_annotation/json_annotation.dart';

part 'item_notes_tag.g.dart';

@JsonSerializable()
class ItemNotesTag {
  bool custom;
  String tagId;
  String customName;
  String customColorHex;
  String customIconName;

  ItemNotesTag(
      {this.custom = false,
      this.tagId,
      this.customName = "",
      this.customColorHex = "",
      this.customIconName = ""});

  factory ItemNotesTag.fromJson(dynamic json) {
    return _$ItemNotesTagFromJson(json);
  }

  dynamic toJson() {
    return _$ItemNotesTagToJson(this);
  }
}
