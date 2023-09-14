import 'package:bungie_api/enums/destiny_component_type.dart';

class ProfileComponentGroups {
  static const List<DestinyComponentType> basicProfile = [
    DestinyComponentType.Transitory,
    DestinyComponentType.Characters,
    DestinyComponentType.CharacterProgressions,
    DestinyComponentType.CharacterActivities,
    DestinyComponentType.CharacterEquipment,
    DestinyComponentType.CharacterInventories,
    DestinyComponentType.CharacterLoadouts,
    DestinyComponentType.ProfileInventories,
    DestinyComponentType.ProfileCurrencies,
    DestinyComponentType.ItemInstances,
    DestinyComponentType.ItemStats,
    DestinyComponentType.ItemObjectives,
    DestinyComponentType.ItemSockets,
    DestinyComponentType.ItemPlugObjectives,
    DestinyComponentType.ItemObjectives,
    DestinyComponentType.ItemReusablePlugs,
    DestinyComponentType.StringVariables,
    DestinyComponentType.ProfileProgression,
    DestinyComponentType.Records,
  ];

  static const List<DestinyComponentType> collections = [
    DestinyComponentType.Collectibles,
    DestinyComponentType.PresentationNodes,
  ];

  static const List<DestinyComponentType> triumphs = [
    DestinyComponentType.Metrics,
    DestinyComponentType.PresentationNodes,
  ];
}
