import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/widgets/details_item_perks.widget.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/sockets/paginated_plug_grid_view.dart';
import 'package:little_light/shared/widgets/sockets/perk_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

import 'details_item_cover_persistent_collapsible_container.dart';

const _randomPerkIconHash = 29505215;
const _animationDuration = const Duration(milliseconds: 300);

class DetailsItemCoverPerksWidget extends DetailsItemPerksWidget {
  final double pixelSize;

  DetailsItemCoverPerksWidget(DestinyItemSocketCategoryDefinition socketCategory, {this.pixelSize = 1})
      : super(socketCategory);

  @override
  Widget build(BuildContext context) {
    final socketCategoryHash = socketCategory.socketCategoryHash;
    final state = context.watch<SocketControllerBloc>();
    final sockets = state.socketsForCategory(socketCategory);
    if (sockets == null) return Container();
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20 * pixelSize),
        child: DetailsItemCoverPersistentCollapsibleContainer(
          title: ManifestText<DestinySocketCategoryDefinition>(socketCategoryHash),
          persistenceID: 'item cover perks $socketCategoryHash',
          content: buildContent(context),
          pixelSize: pixelSize,
        ));
  }

  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildPerks(context),
        buildRandomRolls(context),
      ],
    );
  }

  Widget buildPerks(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final sockets = state.socketsForCategory(socketCategory);
    if (sockets == null) return Container();
    return Stack(children: [
      Positioned.fill(
          child: Image.asset(
        "assets/imgs/perks_grid.png",
        repeat: ImageRepeat.repeat,
        alignment: Alignment.topCenter,
        scale: 1 / pixelSize,
      )),
      Container(
        padding: EdgeInsets.all(8 * pixelSize),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: sockets.map((e) => buildSocket(context, e)).foldIndexed<List<Widget>>(
                <Widget>[],
                (index, list, element) =>
                    list +
                    [
                      Flexible(child: element),
                      if (index < sockets.length - 1) buildDivider(context),
                    ]).toList(),
          ),
        ),
      ),
    ]);
  }

  Widget buildDivider(BuildContext context) {
    return Container(
      width: 1 * pixelSize,
      margin: EdgeInsets.symmetric(horizontal: 4 * pixelSize, vertical: 8 * pixelSize),
      color: context.theme.onSurfaceLayers.layer3,
    );
  }

  Widget buildSocket(BuildContext context, PlugSocket socket) {
    final state = context.watch<SocketControllerBloc>();
    final bloc = context.read<SocketControllerBloc>();
    final itemHash = state.itemHash;
    if (itemHash == null) return Container();
    final hasRandomPlugs = state.randomPlugHashesForSocket(socket.index)?.isNotEmpty ?? false;
    final available = socket.availablePlugHashes;
    final selected = state.selectedPlugHashForSocket(socket.index);
    final equipped = state.equippedPlugHashForSocket(socket.index);
    final random = [selected, equipped].whereType<int>().firstWhereOrNull((h) => !available.contains(h));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: socket.availablePlugHashes.map((plugHash) {
            final isPlugSelectable = state.isSelectable(socket.index, plugHash);
            return Container(
                margin: EdgeInsets.all(8 * pixelSize),
                width: 80 * pixelSize,
                height: 80 * pixelSize,
                child: PerkIconWidget(
                  plugItemHash: plugHash,
                  itemHash: itemHash,
                  selectable: isPlugSelectable,
                  available: state.isAvailable(socket.index, plugHash),
                  selected: state.isSelected(socket.index, plugHash),
                  equipped: state.isEquipped(socket.index, plugHash),
                  onTap: () => bloc.toggleSelection(socket.index, plugHash),
                  wishlistIconSize: 28 * pixelSize,
                ));
          }).toList() +
          [
            if (hasRandomPlugs)
              Container(
                  margin: EdgeInsets.all(8 * pixelSize),
                  width: 80 * pixelSize,
                  height: 80 * pixelSize,
                  child: PerkIconWidget(
                    plugItemHash: random ?? _randomPerkIconHash,
                    itemHash: itemHash,
                    selected: selected == random && selected != null,
                    equipped: equipped == random && equipped != null,
                    wishlistIconSize: 28 * pixelSize,
                    onTap: () => bloc.toggleSocketSelection(socket.index),
                  ))
          ],
    );
  }

  Widget buildOptions(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final socketIndex = state.selectedSocketIndexForCategory(socketCategory);
    final itemHash = state.itemHash;
    if (socketIndex == null || itemHash == null)
      return AnimatedContainer(
        duration: _animationDuration,
      );
    final randomPlugHashes = state.randomPlugHashesForSocket(socketIndex);
    if (randomPlugHashes == null || randomPlugHashes.isEmpty) return AnimatedContainer(duration: _animationDuration);
    final availablePlugHashes = state.availablePlugHashesForSocket(socketIndex) ?? [];
    final plugHashes = {...availablePlugHashes, ...randomPlugHashes}.toList();
    return AnimatedContainer(
      duration: _animationDuration,
      key: Key("perk options $socketIndex"),
      padding: EdgeInsets.all(8 * pixelSize),
      child: PaginatedPlugGridView.withExpectedItemSize(
        plugHashes,
        itemBuilder: (plugHash) {
          if (plugHash == null) return Container();
          final bloc = context.watch<SocketControllerBloc>();
          return PerkIconWidget(
            plugItemHash: plugHash,
            itemHash: itemHash,
            selected: state.isSelected(socketIndex, plugHash),
            equipped: state.isEquipped(socketIndex, plugHash),
            onTap: () => bloc.toggleSelection(socketIndex, plugHash),
            wishlistIconSize: 28 * pixelSize,
          );
        },
        expectedItemSize: 80 * pixelSize,
        maxRows: 1,
      ),
    );
  }
}
