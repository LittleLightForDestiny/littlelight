// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bucket_display_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BucketDisplayOptions _$BucketDisplayOptionsFromJson(Map<String, dynamic> json) {
  return BucketDisplayOptions(
    type: _$enumDecodeNullable(_$BucketDisplayTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$BucketDisplayOptionsToJson(
        BucketDisplayOptions instance) =>
    <String, dynamic>{
      'type': _$BucketDisplayTypeEnumMap[instance.type],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$BucketDisplayTypeEnumMap = {
  BucketDisplayType.Hidden: 'Hidden',
  BucketDisplayType.OnlyEquipped: 'OnlyEquipped',
  BucketDisplayType.Large: 'Large',
  BucketDisplayType.Medium: 'Medium',
  BucketDisplayType.Small: 'Small',
};
