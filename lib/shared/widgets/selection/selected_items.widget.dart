import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
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
    return Container(
      color: context.theme.surfaceLayers.layer1,
      child: Column(children: [
        Container(
          height: 1,
          color: context.theme.onSurfaceLayers.layer3,
        ),
        buildHeader(context, items),
        buildSelectedItems(context, items),
        buildOptions(context),
        buildTransferDestinations(context, items),
      ]),
    );
  }

  Widget buildHeader(BuildContext context, List<DestinyItemInfo> items) {
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

  Widget buildSelectedItems(BuildContext context, List<DestinyItemInfo> items) {
    if (items.length == 1) return buildSingleItem(context, items.first);
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
              final hash = item.itemHash;
              final id = item.instanceId;
              if (hash == null) return;
              selectionBloc(context).unselectItem(hash, instanceId: id, stackIndex: item.stackIndex);
            }),
          ),
        ),
      ]),
    );
  }

  Widget buildSingleItem(BuildContext context, DestinyItemInfo item) {
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
              final hash = item.itemHash;
              final id = item.instanceId;
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

  Widget buildTransferDestinations(BuildContext context, List<DestinyItemInfo> items) {
    if (items.length == 1 && items.first.instanceId == null) return buildStackTransfer(context, items.first);
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
            inventoryBloc(context).equipMultiple(items, destination);
            selectionBloc(context).clear();
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
        key: Key("stack-transfer-${item.itemHash}"),
        child: StackTransferWidget(
          total: item.quantity,
          onTransferPressed: (stackSize, destination) {
            final items = selectionBloc(context).selectedItems;
            inventoryBloc(context).transfer(items.first, destination, stackSize: stackSize);
            selectionBloc(context).clear();
          },
          transferDestinations: selectionState(context).transferDestinations,
        ));
  }

  Widget buildOptions(BuildContext context) {
    final state = selectionState(context);
    final bloc = context.read<SelectionBloc>();
    return Container(
        child: Row(children: [
      if (state.canLock)
        buildOption(
          context,
          "Lock".translate(context),
          state.lockBusy ? null : () => bloc.lockSelected(true),
        ),
      if (state.canUnlock)
        buildOption(
          context,
          "Unlock".translate(context),
          state.lockBusy ? null : () => bloc.lockSelected(false),
        ),
      if (state.selectedItems.length == 1)
        buildOption(
          context,
          "Details".translate(context),
          () => bloc.viewDetails(),
        ),
    ]));
  }

  Widget buildOption(BuildContext context, String label, VoidCallback? onTap) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: ElevatedButton(
          onPressed: onTap,
          child: onTap == null ? DefaultLoadingShimmer(child: Text(label)) : Text(label),
        ),
      ),
    );
  }
}
