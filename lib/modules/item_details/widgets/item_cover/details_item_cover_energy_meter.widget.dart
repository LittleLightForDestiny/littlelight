import 'dart:math';
import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/widgets/details_energy_meter.widget.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'details_item_cover_persistent_collapsible_container.dart';

const _energyBarSize = 68.0;

class DetailsItemCoverEnergyMeterWidget extends DetailsEnergyMeterWidget {
  final double pixelSize;

  double get energyBarSize => _energyBarSize * pixelSize;

  DetailsItemCoverEnergyMeterWidget(
    DestinyItemSocketCategoryDefinition socketCategory, {
    this.pixelSize = 1,
  }) : super(socketCategory);

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
          persistenceID: 'item energy meter $socketCategoryHash',
          content: buildContent(context),
          pixelSize: pixelSize,
        ));
  }

  @override
  Widget buildContent(BuildContext context) {
    return buildEnergyCapacities(context);
  }

  Widget buildSocket(BuildContext context, PlugSocket socket) {
    final state = context.watch<SocketControllerBloc>();
    final itemHash = state.itemHash;
    if (itemHash == null) return Container();
    final equippedPlugHash = state.equippedPlugHashForSocket(socket.index);
    if (equippedPlugHash == null) return Container();
    return buildPlug(
      context,
      socket,
      equippedPlugHash,
    );
  }

  Widget buildMainInfo(BuildContext context, PlugSocket socket, int plugItemHash) {
    final state = context.watch<SocketControllerBloc>();
    final equippedAvailable = state.availableEnergyCapacity?.equipped ?? 0;
    final selectedAvailable = state.availableEnergyCapacity?.selected ?? 0;
    final options = socket.availablePlugHashes.where((element) => element != plugItemHash);
    final barBg = context.theme.onSurfaceLayers.layer3.mix(context.theme.surfaceLayers.layer3, 50);
    return Stack(children: [
      Row(children: [
        Expanded(
          child: Container(
            height: energyBarSize,
            padding: EdgeInsets.symmetric(horizontal: 16 * pixelSize),
            color: barBg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "$selectedAvailable",
                  style: context.textTheme.itemPrimaryStatHighDensity.copyWith(fontSize: 36 * pixelSize),
                ),
                Container(
                  width: 16 * pixelSize,
                ),
                Text(
                  "Energy".translate(context).toUpperCase(),
                  style: context.textTheme.caption.copyWith(fontSize: 20 * pixelSize),
                ),
              ],
            ),
          ),
        ),
        if (options.isNotEmpty)
          Container(
            foregroundDecoration: selectedAvailable > equippedAvailable
                ? BoxDecoration(border: Border.all(color: context.theme.primaryLayers.layer2, width: 8 * pixelSize))
                : null,
            margin: EdgeInsets.only(left: 8 * pixelSize),
            padding: EdgeInsets.all(12 * pixelSize),
            width: energyBarSize,
            height: energyBarSize,
            color: barBg,
            child: Image.asset('assets/imgs/energy-type-icon.png'),
          ),
      ]),
      Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final option = options.firstOrNull;
              if (option == null) return;
              context.read<SocketControllerBloc>().toggleSelection(socket.index, option);
            },
          ),
        ),
      ),
    ]);
  }

  Widget buildEnergyPiece(
      BuildContext context, int index, StatValues? available, StatValues? used, double animationValue) {
    final theme = context.theme;
    final maxAvailable = max(available?.equipped ?? 0, available?.selected ?? 0);
    final maxUsed = max(used?.equipped ?? 0, used?.selected ?? 0);
    final isAvailable = index < maxAvailable;
    final isUsed = index < maxUsed;
    if (isAvailable) {
      return Container(
        height: 24 * pixelSize,
        margin: EdgeInsets.all(2 * pixelSize),
        decoration: BoxDecoration(
          border: Border.all(
            width: 4 * pixelSize,
            color: getDiffColor(context, index, available, animationValue),
          ),
          color: isUsed ? getDiffColor(context, index, used, animationValue) : Colors.transparent,
        ),
      );
    }

    return Container(
      height: 12 * pixelSize,
      margin: EdgeInsets.all(3 * pixelSize),
      child: Container(
        color: isUsed ? theme.errorLayers.withOpacity(.8) : context.theme.onSurfaceLayers.layer0.withOpacity(.5),
      ),
    );
  }
}
