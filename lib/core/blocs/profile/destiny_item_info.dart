import 'package:bungie_api/destiny2.dart';

class DestinyItemInfo {
  DestinyItemComponent item;
  String? characterId;
  Map<String, List<DestinyObjectiveProgress>>? plugObjectives;
  Map<String, List<DestinyItemPlugBase>>? reusablePlugs;
  DestinyItemInstanceComponent? instanceInfo;
  List<DestinyItemSocketState>? sockets;
  Map<String, DestinyStat>? stats;
  List<DestinyItemInfo>? duplicates;

  DestinyItemInfo(
    this.item, {
    this.characterId,
    this.plugObjectives,
    this.reusablePlugs,
    this.instanceInfo,
    this.sockets,
    this.stats,
  });
}
