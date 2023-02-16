import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:provider/provider.dart';

class QuickTransferBloc extends ChangeNotifier with ManifestConsumer {
  final ProfileBloc _profileBloc;

  final int? bucketHash;
  final String? characterId;

  List<DestinyItemInfo>? _unfilteredItems;
  List<DestinyItemInfo>? _items;

  QuickTransferBloc(
    BuildContext context, {
    this.bucketHash,
    this.characterId,
  }) : _profileBloc = context.read<ProfileBloc>() {
    _init();
  }
  void _init() async {
    final allItems = _profileBloc.allInstancedItems;
    final hashes = allItems.map((e) => e.itemHash).whereType<int>().toSet();
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final character = _profileBloc.getCharacterById(characterId);
    final characterClass = character?.character.classType;
    final acceptedClasses = [characterClass, DestinyClass.Unknown].whereType<DestinyClass>();
    final unfiltered = allItems.where((item) {
      final def = defs[item.itemHash];
      if (def == null) return false;
      if (item.bucketHash == bucketHash && item.characterId == characterId) return false;
      if (def.inventory?.bucketTypeHash != bucketHash) return false;
      if (!acceptedClasses.contains(def.classType)) return false;
      return true;
    });
    _unfilteredItems = unfiltered.toList();
    _items = unfiltered.toList();
    notifyListeners();
  }

  void filter() async {
    _items = _unfilteredItems?.toList();
    notifyListeners();
  }

  List<DestinyItemInfo>? get items => _items;
}
