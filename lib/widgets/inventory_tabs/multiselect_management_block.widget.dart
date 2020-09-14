import 'package:bungie_api/enums/bucket_scope.dart';
import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/equip_on_character.button.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class MultiselectManagementBlockWidget extends StatelessWidget {
  final InventoryService inventory = new InventoryService();
  final List<ItemWithOwner> items;
  MultiselectManagementBlockWidget({Key key, this.items})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          transferDestinations.length > 0
              ? Expanded(
                  child: buildEquippingBlock(context, "Transfer",
                      transferDestinations, Alignment.centerLeft))
              : null,
          equipDestinations.length > 0
              ? buildEquippingBlock(
                  context, "Equip", equipDestinations, Alignment.centerRight)
              : null
        ].where((value) => value != null).toList(),
      ),
    );
  }

  Widget buildEquippingBlock(BuildContext context, String title,
      List<TransferDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
    return Stack(children: <Widget>[
      Positioned(right: 0, left: 0, child: buildLabel(context, title, align)),
      Column(
        crossAxisAlignment: align == Alignment.centerRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(opacity: 0, child: buildLabel(context, title)),
          buttons(context, destinations, align)
        ],
      )
    ]);
  }

  Widget buildLabel(BuildContext context, String title,
      [Alignment align = Alignment.centerRight]) {
    return Container(
        constraints: BoxConstraints(minWidth: 100),
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: HeaderWidget(
          padding: EdgeInsets.all(4),
          child: Container(
              alignment: align,
              child: TranslatedTextWidget(
                title,
                uppercase: true,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              )),
        ));
  }

  Widget buttons(BuildContext context, List<TransferDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
    return Container(
        alignment: align,
        padding: EdgeInsets.all(8),
        child: Wrap(
            spacing: 4,
            children: destinations
                .map((destination) => EquipOnCharacterButton(
                    key: ObjectKey(destination),
                    iconSize: kToolbarHeight * .75,
                    fontSize: 7,
                    characterId: destination.characterId,
                    type: destination.type,
                    onTap: () {
                      transferTap(destination, context);
                    }))
                .toList()));
  }

  transferTap(TransferDestination destination, BuildContext context) async {
    switch (destination.action) {
      case InventoryAction.Equip:
        {
          inventory.equipMultiple(List.from(items), destination.characterId);
          SelectionService().clear();
          break;
        }
      case InventoryAction.Unequip:
        {
          break;
        }
      case InventoryAction.Transfer:
        {
          inventory.transferMultiple(
              List.from(items), destination.type, destination.characterId);
          SelectionService().clear();
          break;
        }
      case InventoryAction.Pull:
        {
          break;
        }
    }
  }

  List<TransferDestination> get equipDestinations {
    var characters = ProfileService().getCharacters();
    return characters
        .where((c) {
          return items.any((i) {
            var def = ManifestService()
                .getDefinitionFromCache<DestinyInventoryItemDefinition>(
                    i?.item?.itemHash);
            if (def?.equippable == false) return false;
            if (def?.nonTransferrable == true && i?.ownerId != c.characterId)
              return false;
            if (![c?.classType, DestinyClass.Unknown].contains(def?.classType))
              return false;

            var instanceInfo =
                ProfileService().getInstanceInfo(i?.item?.itemInstanceId);
            if (instanceInfo?.isEquipped == true && i.ownerId == c.characterId)
              return false;

            return true;
          });
        })
        .map((c) => TransferDestination(ItemDestination.Character,
            action: InventoryAction.Equip, characterId: c.characterId))
        .toList();
  }

  List<TransferDestination> get transferDestinations {
    var hasTransferrables = false;
    var hasVaultables = false;
    var hasPullables = false;
    var allCharacterIds =
        ProfileService().getCharacters().map((c) => c.characterId);
    Set<String> destinationCharacterIds = Set();

    for (var i in items) {
      var def = ManifestService()
          .getDefinitionFromCache<DestinyInventoryItemDefinition>(
              i.item.itemHash);
      var bucketDef = ManifestService()
          .getDefinitionFromCache<DestinyInventoryBucketDefinition>(
              def?.inventory?.bucketTypeHash);
      var isOnPostmaster = i.item.bucketHash == InventoryBucket.lostItems;
      var isOnVault = i.item.bucketHash == InventoryBucket.general;
      var canBePulled = !(def?.doesPostmasterPullHaveSideEffects ?? false);
      var lockedOnPostmaster = (isOnPostmaster && !canBePulled);
      var canBeTransferred =
          !lockedOnPostmaster && !(def?.nonTransferrable ?? false);
      var isAccountItem = bucketDef?.scope == BucketScope.Account;
      hasTransferrables = hasTransferrables || canBeTransferred;
      hasPullables = hasPullables || (canBePulled && isOnPostmaster);
      hasVaultables = hasVaultables || (canBeTransferred && !isOnVault);
      if (isAccountItem) continue;
      if (isOnPostmaster && canBePulled) {
        destinationCharacterIds.add(i.ownerId);
      }
      if (canBeTransferred) {
        destinationCharacterIds
            .addAll(allCharacterIds.where((id) => id != i.ownerId));
      }
    }

    List<TransferDestination> destinations = destinationCharacterIds
        .map((id) => TransferDestination(ItemDestination.Character,
            characterId: id, action: InventoryAction.Transfer))
        .toList();

    if ((hasTransferrables || hasPullables) && destinations.length == 0) {
      destinations.add(TransferDestination(ItemDestination.Inventory,
          action: InventoryAction.Transfer));
    }
    if (hasVaultables) {
      destinations.add(TransferDestination(ItemDestination.Vault,
          action: InventoryAction.Transfer));
    }
    return destinations;
  }

  List<TransferDestination> get pullDestinations {
    return [];
  }

  List<TransferDestination> get unequipDestinations {
    return [];
  }
}
