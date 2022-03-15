//@dart=2.12

import 'package:json_annotation/json_annotation.dart';

part 'wishlist_index.g.dart';

@JsonSerializable()
class WishlistFile {
  final String? name;
  final String? description;
  final String? url;

  WishlistFile({this.name, this.description, this.url});

  factory WishlistFile.fromJson(Map<String, dynamic> json) => _$WishlistFileFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistFileToJson(this);

  WishlistFile copyWith({
    String? name,
    String? description,
    String? url,
  }) =>
      WishlistFile(
        name: name ?? this.name,
        description: description ?? this.description,
        url: url ?? this.url,
      );
}

@JsonSerializable()
class WishlistFolder {
  final String? name;
  final String? description;
  final List<WishlistFolder>? folders;
  final List<WishlistFile>? files;

  WishlistFolder({this.name, this.description, this.folders, this.files});

  factory WishlistFolder.fromJson(Map<String, dynamic> json) => _$WishlistFolderFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistFolderToJson(this);
}
