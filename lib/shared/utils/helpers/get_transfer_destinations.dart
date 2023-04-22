import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:provider/provider.dart';

import '../../models/transfer_destination.dart';

class _Destinations {
  final List<TransferDestination>? equip;
  final List<TransferDestination>? transfer;

  _Destinations({this.equip, this.transfer});
}

Future<_Destinations?> getTransferDestinations(
  BuildContext context,
  List<DestinyCharacterInfo>? characters,
  List<DestinyItemInfo> items,
) async {
  final manifest = context.read<ManifestService>();
  bool canTransferToVault = false;
  bool areAllItemsProfileScoped = true;
  bool canTransferToProfile = false;
  final transferCharacters = <DestinyCharacterInfo>[];
  final equipCharacters = <DestinyCharacterInfo>[];
  if (characters == null) return null;
  for (final char in characters) {
    bool canTransfer = false;
    bool canEquip = false;
    for (final item in items) {
      final hash = item.itemHash;
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
      if (def == null) continue;
      final bucketDef = await manifest.getDefinition<DestinyInventoryBucketDefinition>(def.inventory?.bucketTypeHash);
      bool isOnVault = item.bucketHash == InventoryBucket.general;
      bool isOnPostmaster = item.bucketHash == InventoryBucket.lostItems;

      canTransferToProfile |= isOnVault || isOnPostmaster;
      canTransferToVault |= item.canTransfer(null, def) && !isOnVault;

      if (bucketDef?.scope == BucketScope.Account) {
        canTransfer |= isOnVault && item.canTransfer(char, def);
        continue;
      }
      areAllItemsProfileScoped = false;
      canTransfer |= item.canTransfer(char, def);
      canEquip |= item.canEquip(char, def);
      if (canTransfer && canEquip) break;
    }
    if (canTransfer) transferCharacters.add(char);
    if (canEquip) equipCharacters.add(char);
  }

  final transferDestinations = <TransferDestination>[];
  final equipDestinations = <TransferDestination>[];

  if (areAllItemsProfileScoped) {
    if (canTransferToProfile) transferDestinations.add(TransferDestination(TransferDestinationType.profile));
  } else {
    transferDestinations.addAll(transferCharacters.map((c) => TransferDestination(
          TransferDestinationType.character,
          character: c,
        )));
    equipDestinations.addAll(equipCharacters.map((c) => TransferDestination(
          TransferDestinationType.character,
          character: c,
        )));
  }

  if (canTransferToVault) {
    transferDestinations.add(TransferDestination(TransferDestinationType.vault));
  }

  return _Destinations(equip: equipDestinations, transfer: transferDestinations);
}
