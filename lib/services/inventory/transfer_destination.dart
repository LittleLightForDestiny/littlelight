import 'enums/item_destination.dart';

class TransferDestination {
  final String? characterId;
  final ItemDestination type;
  final InventoryAction action;

  TransferDestination(this.type,
      {this.action = InventoryAction.Transfer, this.characterId});
}

enum InventoryAction { Transfer, Equip, Unequip, Pull }
