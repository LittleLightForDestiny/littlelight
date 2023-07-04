import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/item_details/widgets/details_item_supers.widget.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/sockets/super_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

import 'details_item_cover_persistent_collapsible_container.dart';

class DetailsItemCoverSupersWidget extends DetailsItemSupersWidget {
  final double pixelSize;
  DetailsItemCoverSupersWidget(DestinyItemSocketCategoryDefinition socketCategory, {this.pixelSize = 1})
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
          persistenceID: 'item cover supers $socketCategoryHash',
          content: buildContent(context),
          pixelSize: pixelSize,
        ));
  }

  @override
  Widget buildContent(BuildContext context) {
    return buildSupers(context);
  }

  Widget buildSupers(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final sockets = state.socketsForCategory(socketCategory);
    if (sockets == null) return Container();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sockets.map((e) => buildSocket(context, e)).toList(),
      ),
    );
  }

  Widget buildSocket(BuildContext context, PlugSocket socket) {
    final state = context.watch<SocketControllerBloc>();
    final bloc = context.read<SocketControllerBloc>();
    final itemHash = state.itemHash;
    if (itemHash == null) return Container();
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: socket.availablePlugHashes.map((plugHash) {
          final isPlugSelectable = state.isSelectable(socket.index, plugHash);
          return Container(
              margin: EdgeInsets.all(4 * pixelSize),
              constraints: BoxConstraints(maxWidth: 96 * pixelSize, maxHeight: 96 * pixelSize),
              child: SuperIconWidget(
                plugItemHash: plugHash,
                itemHash: itemHash,
                selectable: isPlugSelectable,
                available: state.isAvailable(socket.index, plugHash),
                selected: state.isSelected(socket.index, plugHash),
                equipped: state.isEquipped(socket.index, plugHash),
                onTap: () => bloc.toggleSelection(socket.index, plugHash),
              ));
        }).toList());
  }
}
