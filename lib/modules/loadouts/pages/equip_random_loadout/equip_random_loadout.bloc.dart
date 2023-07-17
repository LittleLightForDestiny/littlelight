import 'dart:math';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/scoped_value_repository.bloc.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:provider/provider.dart';

enum RandomLoadoutOptions {
  Subclass,
  Weapon,
  Armor,
  EnsureExotics,
  ViewItems,
}

class RandomLoadoutOptionTypes extends StorableValue<bool> {
  RandomLoadoutOptionTypes(RandomLoadoutOptions super.key, [super.value]);
}

class EquipRandomLoadoutBloc extends ChangeNotifier {
  @protected
  final ProfileBloc profileBloc;

  @protected
  final ManifestService manifest;

  @protected
  final ScopedValueRepositoryBloc valueStore;

  @protected
  final InventoryBloc inventory;

  @protected
  final SelectionBloc selectionBloc;

  final BuildContext _context;
  final DestinyCharacterInfo character;

  Map<int, InventoryItemInfo?>? _mixedLoadout;
  Map<int, InventoryItemInfo?>? _exoticLoadout;
  List<int>? _exoticSlots;

  EquipRandomLoadoutBloc(this._context, this.character)
      : profileBloc = _context.read<ProfileBloc>(),
        manifest = _context.read<ManifestService>(),
        valueStore = _context.read<ScopedValueRepositoryBloc>(),
        inventory = _context.read<InventoryBloc>(),
        selectionBloc = _context.read<SelectionBloc>(),
        super() {
    _init();
  }

  _init() {
    valueStore.storeValue(RandomLoadoutOptionTypes(RandomLoadoutOptions.Armor, true));
    valueStore.storeValue(RandomLoadoutOptionTypes(RandomLoadoutOptions.Weapon, true));
    valueStore.storeValue(RandomLoadoutOptionTypes(RandomLoadoutOptions.Subclass, true));
    roll();
  }

  void roll() async {
    final allItems = profileBloc.allInstancedItems;
    final hashes = allItems.map((e) => e.itemHash);
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final slots = [
      InventoryBucket.subclass,
      ...InventoryBucket.weaponBucketHashes,
      ...InventoryBucket.armorBucketHashes
    ];
    final items = <int, List<InventoryItemInfo>>{};
    final exotics = <int, List<InventoryItemInfo>>{};
    final nonExotics = <int, List<InventoryItemInfo>>{};
    allItems.forEach((i) {
      final def = defs[i.itemHash];
      final bucket = def?.inventory?.bucketTypeHash;
      final isAcceptableBucket = slots.contains(bucket);
      if (!isAcceptableBucket || bucket == null) return;
      final isAcceptableClass = [character.character.classType, DestinyClass.Unknown].contains(def?.classType);
      if (!isAcceptableClass) return;
      final isExotic = def?.inventory?.tierType == TierType.Exotic;
      (items[bucket] ??= []).add(i);
      isExotic ? (exotics[bucket] ??= []).add(i) : (nonExotics[bucket] ??= []).add(i);
    });
    final nonExoticLoadout = <int, InventoryItemInfo?>{};
    final mixedLoadout = <int, InventoryItemInfo?>{};
    final exoticLoadout = <int, InventoryItemInfo?>{};
    final mixedExoticSlots = <int>[];
    final exoticSlots = <int>[];
    for (final s in slots) {
      final mixed = items[s]?.elementAt(Random().nextInt(items[s]?.length ?? 0));
      final def = defs[mixed?.itemHash];
      mixedLoadout[s] = mixed;
      if (def?.inventory?.tierType == TierType.Exotic) {
        exoticLoadout[s] = mixed;
        nonExoticLoadout[s] = nonExotics[s]?.elementAtOrNull(Random().nextInt(nonExotics[s]?.length ?? 0));
        mixedExoticSlots.add(s);
      } else {
        nonExoticLoadout[s] = mixed;
        exoticLoadout[s] = exotics[s]?.elementAtOrNull(Random().nextInt(exotics[s]?.length ?? 0));
      }
      if (exoticLoadout[s] != null) {
        exoticSlots.add(s);
      }
    }

    final exoticWeaponSlots = exoticSlots.where((s) => InventoryBucket.weaponBucketHashes.contains(s)).toList();
    final mixedExoticWeaponSlots =
        mixedExoticSlots.where((s) => InventoryBucket.weaponBucketHashes.contains(s)).toList();
    int? exoticWeaponSlot = exoticWeaponSlots[Random().nextInt(exoticWeaponSlots.length)];
    if (mixedExoticWeaponSlots.length > 0) {
      exoticWeaponSlot = mixedExoticWeaponSlots[Random().nextInt(mixedExoticWeaponSlots.length)];
    }

    final exoticArmorSlots = exoticSlots.where((s) => InventoryBucket.armorBucketHashes.contains(s)).toList();
    final mixedExoticArmorSlots = mixedExoticSlots.where((s) => InventoryBucket.armorBucketHashes.contains(s)).toList();
    int? exoticArmorSlot = exoticArmorSlots[Random().nextInt(exoticArmorSlots.length)];
    if (mixedExoticArmorSlots.length > 0) {
      exoticArmorSlot = mixedExoticArmorSlots[Random().nextInt(mixedExoticArmorSlots.length)];
    }

    this._exoticSlots = [exoticWeaponSlot, exoticArmorSlot].whereType<int>().toList();
    for (final s in slots) {
      if (this._exoticSlots?.contains(s) != true) {
        mixedLoadout[s] = nonExoticLoadout[s];
      }
    }
    _mixedLoadout = mixedLoadout;
    _exoticLoadout = exoticLoadout;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Map<int, InventoryItemInfo?>? get loadout {
    final loadout = Map<int, InventoryItemInfo?>.from(_mixedLoadout ?? <int, InventoryItemInfo>{});
    final ensureExotics =
        valueStore.getValue(RandomLoadoutOptionTypes(RandomLoadoutOptions.EnsureExotics))?.value ?? false;
    final exoticSlots = _exoticSlots;
    if (ensureExotics && exoticSlots != null) {
      for (final s in exoticSlots) {
        loadout[s] = _exoticLoadout?[s];
      }
    }
    final subclass = valueStore.getValue(RandomLoadoutOptionTypes(RandomLoadoutOptions.Subclass))?.value ?? false;
    final weapons = valueStore.getValue(RandomLoadoutOptionTypes(RandomLoadoutOptions.Weapon))?.value ?? false;
    final armor = valueStore.getValue(RandomLoadoutOptionTypes(RandomLoadoutOptions.Armor))?.value ?? false;
    if (!subclass) {
      loadout[InventoryBucket.subclass] = null;
    }
    if (!weapons) {
      loadout[InventoryBucket.kineticWeapons] = null;
      loadout[InventoryBucket.energyWeapons] = null;
      loadout[InventoryBucket.powerWeapons] = null;
    }
    if (!armor) {
      loadout[InventoryBucket.helmet] = null;
      loadout[InventoryBucket.gauntlets] = null;
      loadout[InventoryBucket.chestArmor] = null;
      loadout[InventoryBucket.legArmor] = null;
      loadout[InventoryBucket.classArmor] = null;
    }

    return loadout;
  }

  void equip() async {
    final newLoadout = LoadoutItemIndex("Random loadout".translate(_context, useReadContext: true));
    final loadout = this.loadout;
    if (loadout == null) return;
    for (final i in loadout.values) {
      await newLoadout.addItem(manifest, i, equipped: true);
    }

    inventory.equipLoadout(newLoadout, character.characterId);

    Navigator.of(_context).pop();
  }

  void select() {
    final loadout = this.loadout;
    if (loadout == null) return;
    selectionBloc.selectItems(loadout.values.whereType<InventoryItemInfo>().toList());
    Navigator.of(_context).pop();
  }

  void cancel() {
    Navigator.of(_context).pop();
  }
}
