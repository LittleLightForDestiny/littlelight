// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'wishlist_index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistFile _$WishlistFileFromJson(Map<String, dynamic> json) => WishlistFile(
      name: json['name'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$WishlistFileToJson(WishlistFile instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
    };

WishlistFolder _$WishlistFolderFromJson(Map<String, dynamic> json) => WishlistFolder(
      name: json['name'] as String?,
      description: json['description'] as String?,
      folders:
          (json['folders'] as List<dynamic>?)?.map((e) => WishlistFolder.fromJson(e as Map<String, dynamic>)).toList(),
      files: (json['files'] as List<dynamic>?)?.map((e) => WishlistFile.fromJson(e as Map<String, dynamic>)).toList(),
    );

Map<String, dynamic> _$WishlistFolderToJson(WishlistFolder instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'folders': instance.folders,
      'files': instance.files,
    };
