import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/sockets/perk_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

class DetailsItemIntrinsicPerkWidget extends StatelessWidget {
  final DestinyItemSocketCategoryDefinition category;

  const DetailsItemIntrinsicPerkWidget(
    DestinyItemSocketCategoryDefinition this.category, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: ManifestText<DestinySocketCategoryDefinition>(category.socketCategoryHash),
          content: buildContent(context),
          persistenceID: 'intrinsic perks ${category.socketCategoryHash}',
        ));
  }

  Widget buildContent(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    return Column(
      children: buildPlugs(context, state),
    );
  }

  List<Widget> buildPlugs(BuildContext context, SocketControllerBloc state) {
    final socketPlugs = state.socketsForCategory(category);
    if (socketPlugs == null) return [];
    return socketPlugs
        .map((socket) => socket.availablePlugHashes.map((plugHash) => buildPlug(context, socket.index, plugHash)))
        .flattened
        .toList();
  }

  Widget buildPlug(BuildContext context, int socketIndex, int plugHash) {
    final state = context.watch<SocketControllerBloc>();
    final bloc = context.read<SocketControllerBloc>();
    final itemHash = state.itemHash;
    if (itemHash == null) return Container();
    if (state.isEquipped(socketIndex, plugHash) == false) return Container();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 64,
            child: PerkIconWidget(
              plugItemHash: plugHash,
              itemHash: itemHash,
              selected: state.isSelected(socketIndex, plugHash),
              equipped: state.isEquipped(socketIndex, plugHash),
              onTap: () => bloc.toggleSelection(socketIndex, plugHash),
            )),
        SizedBox(width: 16),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ManifestText<DestinyInventoryItemDefinition>(
              plugHash,
              uppercase: true,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(height: 4),
            ManifestText<DestinyInventoryItemDefinition>(
              plugHash,
              textExtractor: (def) => def.displayProperties?.description,
              softWrap: true,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            ),
          ],
        ))
      ],
    );
  }
}
