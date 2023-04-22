import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/widgets/transfer_destinations/stack_transfer.widget.dart';
import 'package:little_light/shared/widgets/transfer_destinations/transfer_destinations.widget.dart';

typedef OnTransferAction = void Function(TransferActionType actionType, TransferDestination destination, int stackSize);

class DetailsTransferBlockWidget extends StatelessWidget {
  final OnTransferAction? onAction;
  final List<TransferDestination>? transferDestinations;
  final List<TransferDestination>? equipDestinations;
  final DestinyItemInfo item;
  DetailsTransferBlockWidget(this.item,
      {this.transferDestinations = const [], this.equipDestinations = const [], this.onAction});

  @override
  Widget build(BuildContext context) {
    if (item.instanceId == null) {
      final destinations = transferDestinations;
      if (destinations == null) return Container();
      return StackTransferWidget(
        total: item.quantity,
        onTransferPressed: (stackSize, destination) {
          onAction?.call(TransferActionType.Transfer, destination, stackSize);
        },
        transferDestinations: destinations,
      );
    }
    return TransferDestinationsWidget(
      transferDestinations: transferDestinations,
      equipDestinations: equipDestinations,
      onAction: (type, destination) {
        onAction?.call(type, destination, 1);
      },
    );
  }
}
