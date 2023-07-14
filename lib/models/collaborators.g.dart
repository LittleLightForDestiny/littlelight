// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaborators.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollaboratorsResponse _$CollaboratorsResponseFromJson(
        Map<String, dynamic> json) =>
    CollaboratorsResponse(
      developers: (json['developers'] as List<dynamic>?)
          ?.map(Collaborator.fromJson)
          .toList(),
      designers: (json['designers'] as List<dynamic>?)
          ?.map(Collaborator.fromJson)
          .toList(),
      curators: (json['curators'] as List<dynamic>?)
          ?.map(Collaborator.fromJson)
          .toList(),
      translators: (json['translators'] as List<dynamic>?)
          ?.map(TranslationLanguage.fromJson)
          .toList(),
      supporters: (json['supporters'] as List<dynamic>?)
          ?.map(Collaborator.fromJson)
          .toList(),
    );

Map<String, dynamic> _$CollaboratorsResponseToJson(
        CollaboratorsResponse instance) =>
    <String, dynamic>{
      'developers': instance.developers,
      'designers': instance.designers,
      'curators': instance.curators,
      'translators': instance.translators,
      'supporters': instance.supporters,
    };

TranslationLanguage _$TranslationLanguageFromJson(Map<String, dynamic> json) =>
    TranslationLanguage(
      languages:
          (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
      translators: (json['translators'] as List<dynamic>)
          .map(Collaborator.fromJson)
          .toList(),
    );

Map<String, dynamic> _$TranslationLanguageToJson(
        TranslationLanguage instance) =>
    <String, dynamic>{
      'languages': instance.languages,
      'translators': instance.translators,
    };

Collaborator _$CollaboratorFromJson(Map<String, dynamic> json) => Collaborator(
      membershipId: json['membershipId'] as String,
      membershipType:
          $enumDecode(_$BungieMembershipTypeEnumMap, json['membershipType']),
      link: json['link'] as String?,
    );

Map<String, dynamic> _$CollaboratorToJson(Collaborator instance) =>
    <String, dynamic>{
      'membershipId': instance.membershipId,
      'membershipType': _$BungieMembershipTypeEnumMap[instance.membershipType]!,
      'link': instance.link,
    };

const _$BungieMembershipTypeEnumMap = {
  BungieMembershipType.None: 0,
  BungieMembershipType.TigerXbox: 1,
  BungieMembershipType.TigerPsn: 2,
  BungieMembershipType.TigerSteam: 3,
  BungieMembershipType.TigerBlizzard: 4,
  BungieMembershipType.TigerStadia: 5,
  BungieMembershipType.TigerEgs: 6,
  BungieMembershipType.TigerDemon: 10,
  BungieMembershipType.BungieNext: 254,
  BungieMembershipType.All: -1,
  BungieMembershipType.ProtectedInvalidEnumValue: 999999999,
};
