import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'destiny_item_info.dart';

class DefinitionItemInfo extends DestinyItemInfo {
  final DestinyInventoryItemDefinition _definition;

  factory DefinitionItemInfo.fromDefinition(DestinyInventoryItemDefinition definition) {
    final sockets = definition.sockets?.socketEntries?.map((s) {
      final initialHash = s.singleInitialItemHash ?? 0;
      final firstReusable = s.reusablePlugItems?.firstOrNull?.plugItemHash ?? 0;
      final plug = [initialHash, firstReusable].firstWhereOrNull((p) => p != 0);
      final visible = (s.defaultVisible ?? false) && plug != null;
      return DestinyItemSocketState()
        ..plugHash = plug
        ..isEnabled = visible
        ..isVisible = visible;
    }).toList();

    return DefinitionItemInfo(definition, sockets: sockets);
  }

  DefinitionItemInfo(
    this._definition, {
    Map<String, List<DestinyItemPlugBase>>? reusablePlugs,
    List<DestinyItemSocketState>? sockets,
    Map<String, DestinyStat>? stats,
    int? stackIndex,
  }) : super(
          characterId: null,
          reusablePlugs: reusablePlugs,
          sockets: sockets,
          stats: stats,
          stackIndex: stackIndex,
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

  @override
  int? get overrideStyleItemHash => null;

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
