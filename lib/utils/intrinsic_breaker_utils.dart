import 'package:collection/collection.dart';
import 'package:bungie_api/src/enums/destiny_breaker_type.dart';
import 'package:bungie_api/src/enums/destiny_item_type.dart';
import 'package:bungie_api/src/enums/tier_type.dart';
import 'package:bungie_api/src/models/destiny_inventory_item_definition.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/src/provider.dart';

const _intrinsicTraitCategory = 3956125808;

const Map<int, DestinyBreakerType> _breakerPerkHashes = {
  3469621377: DestinyBreakerType.ShieldPiercing,
  472686235: DestinyBreakerType.Disruption,
  2917776374: DestinyBreakerType.Stagger,
};

class IntrinsicBreakerUtils {
  static DestinyBreakerType? getBreakerType(
    BuildContext context,
    DestinyInventoryItemDefinition? itemDef, {
    int? plugHash,
  }) {
    if (itemDef == null) return null;
    if (itemDef.itemType != DestinyItemType.Weapon) return null;
    if (itemDef.inventory?.tierType == TierType.Exotic) {
      if (itemDef.breakerType != DestinyBreakerType.None) return itemDef.breakerType;
      final weaponsMissingBreaker = context.read<LittleLightDataBloc>().gameData?.weaponsMissingBreakerType ?? {};
      if (weaponsMissingBreaker.containsKey(itemDef.hash)) return weaponsMissingBreaker[itemDef.hash];
    }
    final pHash = plugHash ?? _intrinsicPlugHash(itemDef);
    final plugDef = context.definition<DestinyInventoryItemDefinition>(pHash);
    return _intrinsicPlugBreakerType(plugDef);
  }

  static Future<DestinyBreakerType?> getWeaponBreakerType(
    ManifestService manifest,
    LittleLightDataBloc littleLightData,
    int? itemHash,
  ) async {
    if (itemHash == null) return null;
    final itemDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    if (itemDef == null) return null;
    if (itemDef.itemType != DestinyItemType.Weapon) return null;
    if (itemDef.inventory?.tierType == TierType.Exotic) {
      if (itemDef.breakerType != DestinyBreakerType.None) return itemDef.breakerType;
      final weaponsMissingBreaker = littleLightData.gameData?.weaponsMissingBreakerType ?? {};
      if (weaponsMissingBreaker.containsKey(itemDef.hash)) return weaponsMissingBreaker[itemDef.hash];
    }
    final plugHash = _intrinsicPlugHash(itemDef);
    final plugDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(plugHash);
    return _intrinsicPlugBreakerType(plugDef);
  }

  static DestinyBreakerType? _intrinsicPlugBreakerType(DestinyInventoryItemDefinition? plugDef) {
    final breakerHash = plugDef?.perks
        ?.map((e) => e.perkHash)
        .firstWhereOrNull((p) => _breakerPerkHashes.containsKey(p));
    return _breakerPerkHashes[breakerHash];
  }

  static int? _intrinsicPlugHash(DestinyInventoryItemDefinition? itemDef) {
    return itemDef?.sockets?.socketEntries
        ?.firstWhereOrNull((s) => s.socketTypeHash == _intrinsicTraitCategory)
        ?.singleInitialItemHash;
  }
}
