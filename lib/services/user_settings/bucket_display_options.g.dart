// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'bucket_display_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BucketDisplayOptions _$BucketDisplayOptionsFromJson(Map<String, dynamic> json) {
  return BucketDisplayOptions(
    type: _$enumDecode(_$BucketDisplayTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$BucketDisplayOptionsToJson(
        BucketDisplayOptions instance) =>
    <String, dynamic>{
      'type': _$BucketDisplayTypeEnumMap[instance.type],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$BucketDisplayTypeEnumMap = {
  BucketDisplayType.Hidden: 'Hidden',
  BucketDisplayType.OnlyEquipped: 'OnlyEquipped',
  BucketDisplayType.Large: 'Large',
  BucketDisplayType.Medium: 'Medium',
  BucketDisplayType.Small: 'Small',
};
