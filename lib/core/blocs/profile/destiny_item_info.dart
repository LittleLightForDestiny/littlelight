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
  int? stackIndex;

  DestinyItemInfo(
    this.item, {
    this.characterId,
    this.plugObjectives,
    this.reusablePlugs,
    this.instanceInfo,
    this.sockets,
    this.stats,
    this.stackIndex,
  });

  int get quantity => item.quantity ?? 1;
  void set quantity(int count) => item.quantity = count;
  int? get itemHash => item.itemHash;
  int? get bucketHash => item.bucketHash;

  String? get instanceId => item.itemInstanceId;

  DestinyItemInfo clone() {
    final json = this.item.toJson();

    final item = DestinyItemComponent.fromJson(json);
    return DestinyItemInfo(
      item,
      characterId: characterId,
    );
  }
}
