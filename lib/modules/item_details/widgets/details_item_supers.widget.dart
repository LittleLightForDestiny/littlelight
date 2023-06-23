import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/modules/item_details/widgets/details_plug_info.widget.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/sockets/perk_icon.widget.dart';
import 'package:little_light/shared/widgets/sockets/super_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

class DetailsItemSupersWidget extends StatelessWidget {
  final DestinyItemSocketCategoryDefinition socketCategory;
  DetailsItemSupersWidget(this.socketCategory);

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
          persistenceID: 'item supers $socketCategoryHash',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildSupers(context),
        DetailsPlugInfoWidget(
          category: socketCategory,
        )
      ],
    );
  }

  Widget buildSupers(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sockets.map((e) => buildSocket(context, e)).toList(),
        ),
      ),
    ]);
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
              margin: EdgeInsets.all(4),
              constraints: BoxConstraints(maxWidth: PerkIconWidget.maxIconSize, maxHeight: PerkIconWidget.maxIconSize),
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
