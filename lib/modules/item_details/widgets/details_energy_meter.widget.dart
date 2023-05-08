import 'dart:math';

import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/modules/item_details/widgets/details_plug_info.widget.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:little_light/shared/widgets/animations/ping_pong_animation.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';

const _energyBarSize = 48.0;

class DetailsEnergyMeterWidget extends StatelessWidget {
  final DestinyItemSocketCategoryDefinition socketCategory;
  DetailsEnergyMeterWidget(this.socketCategory);

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
        buildEnergyCapacities(context),
        DetailsPlugInfoWidget(
          category: socketCategory,
        )
      ],
    );
  }

  Widget buildEnergyCapacities(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final sockets = state.socketsForCategory(socketCategory);
    if (sockets == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sockets.map((e) => buildSocket(context, e)).toList(),
    );
  }

  Widget buildSocket(BuildContext context, PlugSocket socket) {
    final state = context.watch<SocketControllerBloc>();
    final itemHash = state.itemHash;
    if (itemHash == null) return Container();
    final equippedPlugHash = state.equippedPlugHashForSocket(socket.index);
    if (equippedPlugHash == null) return Container();
    return Container(
      padding: EdgeInsets.all(4),
      child: buildPlug(
        context,
        socket,
        equippedPlugHash,
      ),
    );
  }

  Widget buildPlug(BuildContext context, PlugSocket socket, int plugItemHash) {
    return Column(children: [
      buildMainInfo(context, socket, plugItemHash),
      buildBars(context, plugItemHash),
    ]);
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
            height: _energyBarSize,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: barBg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "$selectedAvailable",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Container(
                  width: 4,
                ),
                Text(
                  "Energy".translate(context).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        if (options.isNotEmpty)
          Container(
            foregroundDecoration: selectedAvailable > equippedAvailable
                ? BoxDecoration(border: Border.all(color: context.theme.primaryLayers.layer2, width: 4))
                : null,
            margin: EdgeInsets.only(left: 4),
            padding: EdgeInsets.all(8),
            width: _energyBarSize,
            height: _energyBarSize,
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

  Widget buildBars(BuildContext context, int plugItemHash) {
    final state = context.watch<SocketControllerBloc>();
    final total = state.availableEnergyCapacity;
    final used = state.usedEnergyCapacity;
    return PingPongAnimationBuilder(
      (controller) => Container(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: List.generate(
              10,
              (index) => Expanded(child: buildEnergyPiece(context, index, total, used, controller.value)),
            ),
          )),
      playing: true,
      duration: Duration(seconds: 1),
    );
  }

  Color getDiffColor(BuildContext context, int index, StatValues? stat, double animation) {
    final neutral = context.theme.onSurfaceLayers.layer0;
    final minValue = min(stat?.equipped ?? 0, stat?.selected ?? 0);
    if (index < minValue) return neutral;

    if (stat?.diffType == StatDifferenceType.Positive) {
      final success = context.theme.successLayers.layer2;
      return success.mix(neutral, (animation * 50).floor());
    }
    if (stat?.diffType == StatDifferenceType.Negative) {
      final error = context.theme.errorLayers.layer2;
      return error.mix(neutral, (animation * 50).floor());
    }
    return neutral;
  }

  Widget buildEnergyPiece(
      BuildContext context, int index, StatValues? available, StatValues? used, double animationValue) {
    final theme = LittleLightTheme.of(context);
    final maxAvailable = max(available?.equipped ?? 0, available?.selected ?? 0);
    final maxUsed = max(used?.equipped ?? 0, used?.selected ?? 0);
    final isAvailable = index < maxAvailable;
    final isUsed = index < maxUsed;
    if (isAvailable) {
      return Container(
        height: 20,
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            width: 3,
            color: getDiffColor(context, index, available, animationValue),
          ),
          color: isUsed ? getDiffColor(context, index, used, animationValue) : Colors.transparent,
        ),
      );
    }

    return Container(
      height: 8,
      margin: EdgeInsets.all(2),
      child: Container(
        color: isUsed ? theme.errorLayers.withOpacity(.8) : context.theme.onSurfaceLayers.layer0.withOpacity(.5),
      ),
    );
  }
}
