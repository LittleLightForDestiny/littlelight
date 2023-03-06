import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/selection/selected_item_instance.widget.dart';
import 'package:little_light/shared/widgets/selection/selected_item_thumb.widget.dart';
import 'package:little_light/shared/widgets/transfer_destinations/stack_transfer.widget.dart';
import 'package:little_light/shared/widgets/transfer_destinations/transfer_destinations.widget.dart';
import 'package:provider/provider.dart';

const _selectedItemSize = 72.0;
const _instancedItemHeight = 96.0;

class SelectedItemsWidget extends StatelessWidget {
  SelectionBloc selectionBloc(BuildContext context) => context.read<SelectionBloc>();
  SelectionBloc selectionState(BuildContext context) => context.watch<SelectionBloc>();
  InventoryBloc inventoryBloc(BuildContext context) => context.read<InventoryBloc>();
  @override
  Widget build(BuildContext context) {
    if (!selectionState(context).hasSelection) return Container();
    final items = selectionState(context).selectedItems;
    if (items.length > 1) {
      return buildMultiItemSelection(context, items);
    }
    final item = items.firstOrNull;
    if (item == null) return Container();
    if (item.item.itemInstanceId == null) {
      return buildStackedItemSelection(context, item);
    }
    return buildInstancedItemSelection(context, item);
  }

  Widget buildMultiItemSelection(BuildContext context, List<DestinyItemInfo> items) {
    return Container(
      color: context.theme.surfaceLayers.layer1,
      child: Column(children: [
        buildMultiItemSelectionHeader(context, items),
        buildSelectedItemList(context, items),
        buildTransferDestinations(context),
      ]),
    );
  }

  Widget buildInstancedItemSelection(BuildContext context, DestinyItemInfo item) {
    return Container(
      color: context.theme.surfaceLayers.layer1,
      child: Column(children: [
        buildMultiItemSelectionHeader(context, [item]),
        buildInstancedItem(context, item),
        buildTransferDestinations(context),
      ]),
    );
  }

  Widget buildStackedItemSelection(BuildContext context, DestinyItemInfo item) {
    return Container(
      color: context.theme.surfaceLayers.layer1,
      child: Column(children: [
        buildMultiItemSelectionHeader(context, [item]),
        buildInstancedItem(context, item),
        buildStackTransfer(context, item),
      ]),
    );
  }

  Widget buildMultiItemSelectionHeader(BuildContext context, List<DestinyItemInfo> items) {
    return Container(
        color: context.theme.secondarySurfaceLayers.layer0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                items.length > 1
                    ? "{itemCount} items selected".translate(
                        context,
                        replace: {"itemCount": "${items.length}"},
                      )
                    : "1 item selected".translate(
                        context,
                      ),
                style: context.textTheme.subtitle,
              ),
            )),
            buildClearButton(context),
          ],
        ));
  }

  Widget buildSelectedItemList(BuildContext context, List<DestinyItemInfo> items) {
    return SizedBox(
        height: _selectedItemSize + 16,
        child: ListView.separated(
          itemCount: items.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8),
          itemBuilder: (BuildContext context, int index) => listItemBuilder(
            context,
            items[index],
          ),
          separatorBuilder: (BuildContext context, int index) => Container(width: 2),
        ));
  }

  Widget listItemBuilder(BuildContext context, DestinyItemInfo item) {
    return SizedBox(
      width: _selectedItemSize,
      height: _selectedItemSize,
      child: Stack(children: [
        SelectedItemThumb(item),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: () {
              final hash = item.item.itemHash;
              final id = item.item.itemInstanceId;
              if (hash == null) return;
              selectionBloc(context).unselectItem(hash, instanceId: id, stackIndex: item.stackIndex);
            }),
          ),
        ),
      ]),
    );
  }

  Widget buildInstancedItem(BuildContext context, DestinyItemInfo item) {
    return SizedBox(
      height: _instancedItemHeight,
      child: Stack(children: [
        SelectedItemInstance(
          item,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: () {
              final hash = item.item.itemHash;
              final id = item.item.itemInstanceId;
              if (hash == null) return;
              selectionBloc(context).unselectItem(hash, instanceId: id, stackIndex: item.stackIndex);
            }),
          ),
        ),
      ]),
    );
  }

  Widget buildClearButton(BuildContext context) {
    return Material(
      color: context.theme.errorLayers.layer0,
      child: InkWell(
        onTap: () => selectionBloc(context).clear(),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(FontAwesomeIcons.circleMinus, size: 16),
              Container(width: 8),
              Text(context.translate("Clear"), style: context.textTheme.button),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTransferDestinations(BuildContext context) {
    return Container(
      child: TransferDestinationsWidget(
        transferDestinations: selectionState(context).transferDestinations,
        equipDestinations: selectionState(context).equipDestinations,
        onAction: (type, destination) {
          final items = selectionBloc(context).selectedItems;
          if (type == TransferActionType.Transfer && items.length > 1) {
            inventoryBloc(context).transferMultiple(items, destination);
            selectionBloc(context).clear();
            return;
          }
          if (type == TransferActionType.Transfer) {
            inventoryBloc(context).transfer(items.first, destination);
            selectionBloc(context).clear();
            return;
          }
          if (type == TransferActionType.Equip && items.length > 1) {
            return;
          }
          if (type == TransferActionType.Equip) {
            inventoryBloc(context).equip(items.first, destination);
            selectionBloc(context).clear();
            return;
          }
        },
      ),
    );
  }

  Widget buildStackTransfer(BuildContext context, DestinyItemInfo item) {
    if (selectionState(context).transferDestinations.isEmpty) return Container();
    return Container(
        key: Key("stack-transfer-${item.item.itemHash}"),
        child: StackTransferWidget(
          total: item.item.quantity ?? 1,
          onTransferPressed: (stackSize, destination) {
            final items = selectionBloc(context).selectedItems;
            inventoryBloc(context).transfer(items.first, destination, stackSize: stackSize);
            selectionBloc(context).clear();
          },
          transferDestinations: selectionState(context).transferDestinations,
        ));
  }
}
