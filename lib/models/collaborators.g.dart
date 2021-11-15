// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'collaborators.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollaboratorsResponse _$CollaboratorsResponseFromJson(
    Map<String, dynamic> json) {
  return CollaboratorsResponse(
    developers: (json['developers'] as List<dynamic>?)
        ?.map((e) => Collaborator.fromJson(e))
        .toList(),
    designers: (json['designers'] as List<dynamic>?)
        ?.map((e) => Collaborator.fromJson(e))
        .toList(),
    curators: (json['curators'] as List<dynamic>?)
        ?.map((e) => Collaborator.fromJson(e))
        .toList(),
    translators: (json['translators'] as List<dynamic>?)
        ?.map((e) => TranslationLanguage.fromJson(e))
        .toList(),
    supporters: (json['supporters'] as List<dynamic>?)
        ?.map((e) => Collaborator.fromJson(e))
        .toList(),
  );
}

Map<String, dynamic> _$CollaboratorsResponseToJson(
        CollaboratorsResponse instance) =>
    <String, dynamic>{
      'developers': instance.developers,
      'designers': instance.designers,
      'curators': instance.curators,
      'translators': instance.translators,
      'supporters': instance.supporters,
    };

TranslationLanguage _$TranslationLanguageFromJson(Map<String, dynamic> json) {
  return TranslationLanguage(
    languages:
        (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
    translators: (json['translators'] as List<dynamic>)
        .map((e) => Collaborator.fromJson(e))
        .toList(),
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
    membershipType:
        _$enumDecode(_$BungieMembershipTypeEnumMap, json['membershipType']),
    link: json['link'] as String?,
  );
}

Map<String, dynamic> _$CollaboratorToJson(Collaborator instance) =>
    <String, dynamic>{
      'membershipId': instance.membershipId,
      'membershipType': _$BungieMembershipTypeEnumMap[instance.membershipType],
      'link': instance.link,
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
  BungieMembershipType.ProtectedInvalidEnumValue: 999999999,
};
