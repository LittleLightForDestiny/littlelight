// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bucket_display_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BucketDisplayOptions _$BucketDisplayOptionsFromJson(
        Map<String, dynamic> json) =>
    BucketDisplayOptions(
      type: $enumDecode(_$BucketDisplayTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$BucketDisplayOptionsToJson(
        BucketDisplayOptions instance) =>
    <String, dynamic>{
      'type': _$BucketDisplayTypeEnumMap[instance.type],
    };

const _$BucketDisplayTypeEnumMap = {
  BucketDisplayType.Hidden: 'Hidden',
  BucketDisplayType.OnlyEquipped: 'OnlyEquipped',
  BucketDisplayType.Large: 'Large',
  BucketDisplayType.Medium: 'Medium',
  BucketDisplayType.Small: 'Small',
};
