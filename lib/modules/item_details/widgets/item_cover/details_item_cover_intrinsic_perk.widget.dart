
import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/widgets/details_item_intrinsic_perk.widget.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/sockets/perk_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

import 'details_item_cover_persistent_collapsible_container.dart';

class DetailsItemCoverIntrinsicPerkWidget extends DetailsItemIntrinsicPerkWidget {
  final double pixelSize;
  DetailsItemCoverIntrinsicPerkWidget(
    DestinyItemSocketCategoryDefinition category, {
    this.pixelSize = 1,
  }) : super(category);

  @override
  Widget build(BuildContext context) {
    final socketCategoryHash = category.socketCategoryHash;
    final state = context.watch<SocketControllerBloc>();
    final sockets = state.socketsForCategory(category);
    if (sockets == null) return Container();
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20 * pixelSize),
        child: DetailsItemCoverPersistentCollapsibleContainer(
          title: ManifestText<DestinySocketCategoryDefinition>(socketCategoryHash),
          persistenceID: 'item cover mods $socketCategoryHash',
          content: buildContent(context),
          pixelSize: pixelSize,
        ));
  }

  @override
  Widget buildContent(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final sockets = state.socketsForCategory(category);
    if (sockets == null) return Container();
    return Stack(children: [
      Positioned.fill(
          child: Opacity(
              opacity: .5,
              child: Image.asset(
                "assets/imgs/perks_grid.png",
                repeat: ImageRepeat.repeat,
                alignment: Alignment.topCenter,
                scale: 1 / pixelSize,
              ))),
      Container(
        padding: EdgeInsets.all(8 * pixelSize),
        child: Column(
          children: buildPlugs(context, state),
        ),
      ),
    ]);
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
        Container(
            width: 96 * pixelSize,
            padding: EdgeInsets.all(16 * pixelSize),
            foregroundDecoration: BoxDecoration(
              border: Border.all(width: 1 * pixelSize, color: context.theme.onSurfaceLayers.withOpacity(.1)),
            ),
            child: PerkIconWidget(
              plugItemHash: plugHash,
              itemHash: itemHash,
              selected: state.isSelected(socketIndex, plugHash),
              equipped: state.isEquipped(socketIndex, plugHash),
              onTap: () => bloc.toggleSelection(socketIndex, plugHash),
            )),
        SizedBox(width: 16 * pixelSize),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ManifestText<DestinyInventoryItemDefinition>(
              plugHash,
              uppercase: true,
              style: context.textTheme.highlight.copyWith(fontSize: 20 * pixelSize),
            ),
            Container(height: 4),
            ManifestText<DestinyInventoryItemDefinition>(
              plugHash,
              textExtractor: (def) => def.displayProperties?.description,
              softWrap: true,
              style: context.textTheme.caption.copyWith(fontSize: 20 * pixelSize),
            ),
          ],
        ))
      ],
    );
  }
}
