import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/sockets/perk_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

const _randomPerkIconHash = 29505215;

class DetailsItemCoverPerksWidget extends StatelessWidget {
  final double pixelSize;
  final DestinyItemSocketCategoryDefinition socketCategory;
  DetailsItemCoverPerksWidget(this.socketCategory, this.pixelSize);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final sockets = state.socketsForCategory(socketCategory);
    if (sockets == null) return Container();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 20 * pixelSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTitle(context),
          buildPerks(context),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4 * pixelSize),
      margin: EdgeInsets.only(bottom: 8 * pixelSize),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: context.theme.onSurfaceLayers,
        width: 1 * pixelSize,
      ))),
      child: ManifestText<DestinySocketCategoryDefinition>(
        socketCategory.socketCategoryHash,
        uppercase: true,
        style: context.textTheme.caption.copyWith(fontSize: 18 * pixelSize),
      ),
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
}
