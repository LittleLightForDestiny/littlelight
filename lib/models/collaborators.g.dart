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
    membershipType: json['membershipType'],
    link: json['link'] as String,
  );
}

Map<String, dynamic> _$CollaboratorToJson(Collaborator instance) =>
    <String, dynamic>{
      'membershipId': instance.membershipId,
      'membershipType': instance.membershipType,
      'link': instance.link,
    };
