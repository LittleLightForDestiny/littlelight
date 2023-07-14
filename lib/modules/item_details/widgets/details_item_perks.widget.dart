import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/modules/item_details/widgets/details_plug_info.widget.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/sockets/paginated_plug_grid_view.dart';
import 'package:little_light/shared/widgets/sockets/perk_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

const _animationDuration = const Duration(milliseconds: 300);
const _randomPerkIconHash = 29505215;

class DetailsItemPerksWidget extends StatelessWidget {
  final DestinyItemSocketCategoryDefinition socketCategory;
  DetailsItemPerksWidget(this.socketCategory);

  @override
  Widget build(BuildContext context) {
    final socketCategoryHash = socketCategory.socketCategoryHash;
    final state = context.watch<SocketControllerBloc>();
    final sockets = state.socketsForCategory(socketCategory);
    if (sockets == null) return Container();
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: ManifestText<DestinySocketCategoryDefinition>(socketCategoryHash),
          persistenceID: 'item perks $socketCategoryHash',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildPerks(context),
        buildRandomRolls(context),
        DetailsPlugInfoWidget(
          category: socketCategory,
        )
      ],
    );
  }

  Widget buildRandomRolls(BuildContext context) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: _animationDuration,
      child: buildOptions(context),
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
      key: Key("mod_options_$socketIndex"),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        borderRadius: BorderRadius.circular(4).copyWith(topLeft: Radius.zero),
      ),
      padding: EdgeInsets.all(8),
      child: PaginatedPlugGridView.withExpectedItemSize(plugHashes, itemBuilder: (plugHash) {
        if (plugHash == null) return Container();
        final bloc = context.watch<SocketControllerBloc>();
        return PerkIconWidget(
          plugItemHash: plugHash,
          itemHash: itemHash,
          selected: state.isSelected(socketIndex, plugHash),
          equipped: state.isEquipped(socketIndex, plugHash),
          onTap: () => bloc.toggleSelection(socketIndex, plugHash),
        );
      }, expectedItemSize: PerkIconWidget.maxIconSize),
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
        scale: 1,
      )),
      Container(
        padding: EdgeInsets.all(4),
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
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
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
                margin: EdgeInsets.all(4),
                constraints:
                    BoxConstraints(maxWidth: PerkIconWidget.maxIconSize, maxHeight: PerkIconWidget.maxIconSize),
                child: PerkIconWidget(
                  plugItemHash: plugHash,
                  itemHash: itemHash,
                  selectable: isPlugSelectable,
                  available: state.isAvailable(socket.index, plugHash),
                  selected: state.isSelected(socket.index, plugHash),
                  equipped: state.isEquipped(socket.index, plugHash),
                  onTap: () => bloc.toggleSelection(socket.index, plugHash),
                ));
          }).toList() +
          [
            if (hasRandomPlugs)
              Container(
                  margin: EdgeInsets.all(4),
                  constraints:
                      BoxConstraints(maxWidth: PerkIconWidget.maxIconSize, maxHeight: PerkIconWidget.maxIconSize),
                  child: PerkIconWidget(
                    plugItemHash: random ?? _randomPerkIconHash,
                    itemHash: itemHash,
                    selected: selected == random && selected != null,
                    equipped: equipped == random && equipped != null,
                    onTap: () => bloc.toggleSocketSelection(socket.index),
                  ))
          ],
    );
  }
}
