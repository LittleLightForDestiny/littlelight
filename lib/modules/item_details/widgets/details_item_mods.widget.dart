import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/blocs/socket_controller.bloc.dart';
import 'package:little_light/modules/item_details/widgets/details_plug_info.widget.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/sockets/mod_icon.widget.dart';
import 'package:little_light/shared/widgets/sockets/paginated_plug_grid_view.dart';
import 'package:little_light/shared/widgets/sockets/perk_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

const _animationDuration = const Duration(milliseconds: 300);

class DetailsItemModsWidget extends StatelessWidget {
  final DestinyItemSocketCategoryDefinition socketCategory;
  DetailsItemModsWidget(this.socketCategory);

  @override
  Widget build(BuildContext context) {
    final socketCategoryHash = socketCategory.socketCategoryHash;
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: ManifestText<DestinySocketCategoryDefinition>(socketCategoryHash),
          persistenceID: 'item_mods_$socketCategoryHash',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildSockets(context),
        buildOptionsContainer(context),
        DetailsPlugInfoWidget(
          category: socketCategory,
        )
      ],
    );
  }

  Widget buildOptionsContainer(BuildContext context) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: _animationDuration,
      child: buildOptions(context),
    );
  }

  Widget buildOptions(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final bloc = context.read<SocketControllerBloc>();
    final sockets = state.socketsForCategory(socketCategory);
    final socketIndex = state.selectedSocketIndex;
    final isSocketFromCurrentCategory = sockets?.any((element) => element.index == socketIndex) ?? false;
    if (socketIndex == null)
      return AnimatedContainer(
        duration: _animationDuration,
      );
    if (!isSocketFromCurrentCategory) return AnimatedContainer(duration: _animationDuration);
    final plugHashes = state.getAvailablePlugHashesForSocket(socketIndex);
    if (plugHashes == null) return AnimatedContainer(duration: _animationDuration);
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
        return ModIconWidget(
          plugHash,
          selected: state.isSelected(socketIndex, plugHash),
          equipped: state.isEquipped(socketIndex, plugHash),
          onTap: () => bloc.toggleSelection(socketIndex, plugHash),
        );
      }, expectedItemSize: PerkIconWidget.maxIconSize),
    );
  }

  Widget buildSockets(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final sockets = state.socketsForCategory(socketCategory);
    if (sockets == null) return Container();
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sockets.map((e) => Flexible(child: buildSocket(context, e))).toList(),
      ),
    );
  }

  Widget buildSocket(BuildContext context, PlugSocket socket) {
    final state = context.watch<SocketControllerBloc>();
    final bloc = context.read<SocketControllerBloc>();
    final itemHash = state.itemHash;
    if (itemHash == null) return Container();
    final equippedPlugHash = state.getEquippedPlugHashForSocket(socket.index);
    if (equippedPlugHash == null) return Container();
    final isSocketSelected = state.selectedSocketIndex == socket.index;
    final selectedPlugHash = state.getSelectedPlugHashForSocket(socket.index);
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          color: isSocketSelected ? context.theme.surfaceLayers.layer1 : Colors.transparent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
        padding: EdgeInsets.all(8),
        child: Container(
          constraints: BoxConstraints(maxWidth: PerkIconWidget.maxIconSize, maxHeight: PerkIconWidget.maxIconSize),
          child: ModIconWidget(
            equippedPlugHash,
            selected: false,
            equipped: isSocketSelected,
            onTap: () => bloc.toggleSocketSelection(socket.index),
          ),
        ),
      ),
      if (selectedPlugHash != null && selectedPlugHash != equippedPlugHash)
        Positioned(
          width: 32,
          height: 32,
          bottom: 2,
          right: 2,
          child: ModIconWidget(
            selectedPlugHash,
            selected: false,
            equipped: true,
          ),
        ),
    ]);
  }
}
