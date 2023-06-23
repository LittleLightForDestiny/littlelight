import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'destiny_item_info.dart';

class DefinitionItemInfo extends DestinyItemInfo {
  final DestinyInventoryItemDefinition _definition;
  factory DefinitionItemInfo.fromDefinition(DestinyInventoryItemDefinition definition) {
    return DefinitionItemInfo(definition);
  }

  DefinitionItemInfo(
    this._definition, {
    Map<String, List<DestinyItemPlugBase>>? reusablePlugs,
    List<DestinyItemSocketState>? sockets,
    Map<String, DestinyStat>? stats,
    DestinyItemObjectivesComponent? objectives,
    int? stackIndex,
  }) : super(
          characterId: null,
          reusablePlugs: reusablePlugs,
          sockets: sockets,
          stats: stats,
          stackIndex: stackIndex,
          objectives: objectives,
        );

  @override
  int? get itemHash => _definition.hash;

  @override
  int get quantity => 1;

  @override
  int? get bucketHash => _definition.inventory?.bucketTypeHash;

  @override
  String? get instanceId => null;

  @override
  int? get primaryStatValue => null;

  @override
  int? get damageTypeHash => _definition.damageTypeHashes?.firstOrNull;

  @override
  DamageType? get damageType => _definition.damageTypes?.firstOrNull;

  @override
  ItemLocation? get location => null;

  @override
  ItemState? get state => null;

  @override
  bool? get lockable => false;

  int? _overrideStyleItemHash;

  set overrideStyleItemHash(int? value) => _overrideStyleItemHash = value;
  @override
  int? get overrideStyleItemHash => _overrideStyleItemHash;

  @override
  int? get versionNumber => null;

  @override
  String? get expirationDate => null;

  @override
  int? get energyCapacity => null;

  @override
  bool? get isEquipped => null;

  @override
  int? get itemLevel => null;

  @override
  int? get quality => null;
}
