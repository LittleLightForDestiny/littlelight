import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/modules/item_details/widgets/details_plug_info.widget.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/sockets/perk_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

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
          persistenceID: 'item_perks_$socketCategoryHash',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildPerks(context),
        DetailsPlugInfoWidget(
          category: socketCategory,
        )
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: socket.availablePlugHashes
          .map((plugHash) => Container(
              margin: EdgeInsets.all(4),
              constraints: BoxConstraints(maxWidth: PerkIconWidget.maxIconSize, maxHeight: PerkIconWidget.maxIconSize),
              child: PerkIconWidget(
                plugItemHash: plugHash,
                itemHash: itemHash,
                selected: state.isSelected(socket.index, plugHash),
                equipped: state.isEquipped(socket.index, plugHash),
                onTap: () => bloc.toggleSelection(socket.index, plugHash),
              )))
          .toList(),
    );
  }
}
