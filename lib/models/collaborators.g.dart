// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaborators.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollaboratorsResponse _$CollaboratorsResponseFromJson(
    Map<String, dynamic> json) {
  return CollaboratorsResponse(
    developers: (json['developers'] as List)
        ?.map((e) => e == null ? null : Collaborator.fromJson(e))
        ?.toList(),
    designers: (json['designers'] as List)
        ?.map((e) => e == null ? null : Collaborator.fromJson(e))
        ?.toList(),
    translators: (json['translators'] as List)
        ?.map((e) => e == null ? null : TranslationLanguage.fromJson(e))
        ?.toList(),
    supporters: (json['supporters'] as List)
        ?.map((e) => e == null ? null : Collaborator.fromJson(e))
        ?.toList(),
  );
}

Map<String, dynamic> _$CollaboratorsResponseToJson(
        CollaboratorsResponse instance) =>
    <String, dynamic>{
      'developers': instance.developers,
      'designers': instance.designers,
      'translators': instance.translators,
      'supporters': instance.supporters,
    };

TranslationLanguage _$TranslationLanguageFromJson(Map<String, dynamic> json) {
  return TranslationLanguage(
    languages: (json['languages'] as List)?.map((e) => e as String)?.toList(),
    translators: (json['translators'] as List)
        ?.map((e) => e == null ? null : Collaborator.fromJson(e))
        ?.toList(),
  );
}

Map<String, dynamic> _$TranslationLanguageToJson(
        TranslationLanguage instance) =>
    <String, dynamic>{
      'languages': instance.languages,
      'translators': instance.translators,
    };

Collaborator _$CollaboratorFromJson(Map<String, dynamic> json) {
  return Collaborator(
    membershipId: json['membershipId'] as String,
    membershipType: _$enumDecodeNullable(
        _$BungieMembershipTypeEnumMap, json['membershipType']),
    link: json['link'] as String,
  );
}

Map<String, dynamic> _$CollaboratorToJson(Collaborator instance) =>
    <String, dynamic>{
      'membershipId': instance.membershipId,
      'membershipType': _$BungieMembershipTypeEnumMap[instance.membershipType],
      'link': instance.link,
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

const _$BungieMembershipTypeEnumMap = {
  BungieMembershipType.None: 0,
  BungieMembershipType.TigerXbox: 1,
  BungieMembershipType.TigerPsn: 2,
  BungieMembershipType.TigerSteam: 3,
  BungieMembershipType.TigerBlizzard: 4,
  BungieMembershipType.TigerStadia: 5,
  BungieMembershipType.TigerDemon: 10,
  BungieMembershipType.BungieNext: 254,
  BungieMembershipType.All: -1,
};
