import 'package:little_light/core/blocs/profile/destiny_item_info.dart';

typedef OnItemInteraction = void Function(DestinyItemInfo);
typedef OnEmptySlotInteraction = void Function(int bucketHash, String characterId);

class ItemInteractionHandlerBloc {
  final OnItemInteraction? onTap;
  final OnItemInteraction? onHold;
  final OnEmptySlotInteraction? onEmptySlotTap;

  ItemInteractionHandlerBloc({
    this.onTap,
    this.onHold,
    this.onEmptySlotTap,
  });
}
