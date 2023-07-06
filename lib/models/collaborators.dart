import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'collaborators.g.dart';

@JsonSerializable()
class CollaboratorsResponse {
  List<Collaborator>? developers;
  List<Collaborator>? designers;
  List<Collaborator>? curators;
  List<TranslationLanguage>? translators;
  List<Collaborator>? supporters;

  CollaboratorsResponse({
    this.developers,
    this.designers,
    this.curators,
    this.translators,
    this.supporters,
  });

  factory CollaboratorsResponse.fromJson(dynamic json) {
    return _$CollaboratorsResponseFromJson(json);
  }

  dynamic toJson() {
    return _$CollaboratorsResponseToJson(this);
  }
}

@JsonSerializable()
class TranslationLanguage {
  List<String> languages;
  List<Collaborator> translators;

  TranslationLanguage({required this.languages, required this.translators});

  factory TranslationLanguage.fromJson(dynamic json) {
    return _$TranslationLanguageFromJson(json);
  }

  dynamic toJson() {
    return _$TranslationLanguageToJson(this);
  }
}

@JsonSerializable()
class Collaborator {
  String membershipId;
  BungieMembershipType membershipType;
  String? link;

  Collaborator({
    required this.membershipId,
    required this.membershipType,
    this.link,
  });

  factory Collaborator.fromJson(dynamic json) {
    return _$CollaboratorFromJson(json);
  }

  dynamic toJson() {
    return _$CollaboratorToJson(this);
  }
}
