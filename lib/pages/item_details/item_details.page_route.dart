import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/pages/item_details/item_details.page.dart';
import 'package:little_light/pages/item_details/item_details.page_container.dart';
import 'package:little_light/utils/item_with_owner.dart';

abstract class ItemDetailsPageArgumentsBase {
  final int itemHash;
  final String? uniqueId;
  final bool hideItemManagement;
  ItemDetailsPageArgumentsBase(this.itemHash, {this.uniqueId, this.hideItemManagement = false});
}

class ItemDetailsPageArguments extends ItemDetailsPageArgumentsBase {
  final ItemWithOwner item;
  ItemDetailsPageArguments({
    required this.item,
    String? uniqueId,
    bool hideItemManagement = false,
  }) : super(
          item.item.itemHash!,
          uniqueId: uniqueId,
          hideItemManagement: hideItemManagement,
        );
}

class ItemInfoPageArguments extends ItemDetailsPageArgumentsBase {
  final DestinyItemInfo item;
  ItemInfoPageArguments({
    required this.item,
    String? uniqueId,
    bool hideItemManagement = false,
  }) : super(
          item.item.itemHash!,
          uniqueId: uniqueId,
          hideItemManagement: hideItemManagement,
        );
}

class DefinitionDetailsPageArguments extends ItemDetailsPageArgumentsBase {
  DefinitionDetailsPageArguments({
    required int itemHash,
    String? uniqueId,
  }) : super(
          itemHash,
          uniqueId: uniqueId,
          hideItemManagement: true,
        );
}

class VendorItemDetailsPageArguments extends ItemDetailsPageArgumentsBase {
  String characterId;

  int vendorHash;

  DestinyVendorSaleItemComponent vendorItem;

  VendorItemDetailsPageArguments({
    required this.characterId,
    required this.vendorHash,
    required this.vendorItem,
    String? uniqueId,
  }) : super(
          vendorItem.itemHash!,
          uniqueId: uniqueId,
          hideItemManagement: true,
        );
}

class ItemDetailsPageRoute extends MaterialPageRoute {
  ItemDetailsPageRoute._({
    Key? key,
    required RouteSettings settings,
  }) : super(settings: settings, builder: (context) => const ItemDetailsPageContainer());

  factory ItemDetailsPageRoute({
    required ItemWithOwner item,
    Key? key,
    String? heroKey,
  }) =>
      ItemDetailsPageRoute._(
          key: key,
          settings: RouteSettings(
            arguments: ItemDetailsPageArguments(item: item, uniqueId: heroKey),
          ));

  factory ItemDetailsPageRoute.itemInfo({required DestinyItemInfo item, Key? key, String? heroString}) =>
      ItemDetailsPageRoute._(
        key: key,
        settings: RouteSettings(
          arguments: ItemInfoPageArguments(item: item),
        ),
      );

  factory ItemDetailsPageRoute.viewOnly({
    required ItemWithOwner item,
    Key? key,
    String? heroKey,
  }) =>
      ItemDetailsPageRoute._(
        key: key,
        settings: RouteSettings(arguments: ItemDetailsPageArguments(item: item)),
      );

  factory ItemDetailsPageRoute.definition({
    required int hash,
    Key? key,
    String? heroKey,
  }) =>
      ItemDetailsPageRoute._(
        key: key,
        settings: RouteSettings(arguments: DefinitionDetailsPageArguments(itemHash: hash)),
      );

  factory ItemDetailsPageRoute.fromVendor({
    Key? key,
    String? heroKey,
    required DestinyItemInstanceComponent instanceInfo,
    required String characterId,
    required DestinyVendorSaleItemComponent vendorItem,
    required int vendorHash,
  }) =>
      ItemDetailsPageRoute._(
        key: key,
        settings: RouteSettings(
            arguments: VendorItemDetailsPageArguments(
          characterId: characterId,
          vendorHash: vendorHash,
          vendorItem: vendorItem,
        )),
      );
}
