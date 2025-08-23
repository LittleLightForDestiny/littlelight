import 'dart:math';
import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/modules/item_details/widgets/details_plug_info.widget.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/sockets/mod_icon.widget.dart';
import 'package:little_light/shared/widgets/scrollable_grid_view/paginated_plug_grid_view.dart';
import 'package:little_light/shared/widgets/sockets/perk_icon.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/shared/widgets/animations/ping_pong_animation.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:provider/provider.dart';

const _animationDuration = const Duration(milliseconds: 300);

class DetailsItemModsWidget extends StatelessWidget {
  final DestinyItemSocketCategoryDefinition socketCategory;
  DetailsItemModsWidget(this.socketCategory);

  bool socketsHaveEnergyMasterwork(BuildContext context, List<PlugSocket> sockets) {
    final bloc = context.read<SocketControllerBloc>();
    return sockets.where((s) {
          final plugHash = bloc.equippedPlugHashForSocket(s.index);
          final def = context.definition<DestinyInventoryItemDefinition>(plugHash);
          final plugCategoryIdentifier = def?.plug?.plugCategoryIdentifier;
          return plugCategoryIdentifier?.contains("plugs.armor.masterworks") ?? false;
        }).firstOrNull !=
        null;
  }

  @override
  Widget build(BuildContext context) {
    final socketCategoryHash = socketCategory.socketCategoryHash;
    final state = context.watch<SocketControllerBloc>();
    final sockets = state.socketsForCategory(socketCategory);
    if (sockets == null) return Container();
    final showEnergyBar = socketsHaveEnergyMasterwork(context, sockets);
    return Container(
      padding: EdgeInsets.all(4),
      child: PersistentCollapsibleContainer(
        title: buildTitle(context, showEnergyBar),
        persistenceID: 'item mods $socketCategoryHash',
        content: buildContent(context, showEnergyBar),
      ),
    );
  }

  Widget buildTitle(BuildContext context, bool showEnergyBar) {
    final state = context.watch<SocketControllerBloc>();
    final socketCategoryHash = socketCategory.socketCategoryHash;
    if (showEnergyBar) {
      final total = state.availableEnergyCapacity?.equipped ?? 0;
      final used = state.usedEnergyCapacity?.selected ?? 0;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ManifestText<DestinySocketCategoryDefinition>(socketCategoryHash),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Text("Energy".translate(context) + ": ${used}/$total"),
          ),
        ],
      );
    }
    return ManifestText<DestinySocketCategoryDefinition>(socketCategoryHash);
  }

  Widget buildContent(BuildContext context, bool showEnergyBar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showEnergyBar) buildBars(context),
        buildSockets(context),
        buildOptionsContainer(context),
        DetailsPlugInfoWidget(
          category: socketCategory,
        ),
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
    final socket = state.selectedSocketForCategory(socketCategory);
    if (socket == null) return AnimatedContainer(duration: _animationDuration);
    final plugHashes = socket.availablePlugHashes;
    final socketIndex = socket.index;
    int initialFocus = 0;
    final equipped = state.equippedPlugHashForSocket(socketIndex);
    final selected = state.selectedPlugHashForSocket(socketIndex);
    if (equipped != null) {
      initialFocus = plugHashes.indexOf(equipped);
    }
    if (selected != null) {
      initialFocus = plugHashes.indexOf(selected);
    }
    if (initialFocus < 0) {
      initialFocus = 0;
    }
    return AnimatedContainer(
      duration: _animationDuration,
      key: Key("mod_options_$socketIndex"),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        borderRadius: BorderRadius.circular(4).copyWith(topLeft: Radius.zero),
      ),
      padding: EdgeInsets.all(8),
      child: PaginatedScrollableGridView.withExpectedItemSize(
        plugHashes,
        itemBuilder: (plugHash) {
          if (plugHash == null) return Container();
          return ModIconWidget(
            plugHash,
            isFavorite: state.isFavoritePlug(plugHash),
            selected: state.isSelected(socketIndex, plugHash),
            equipped: state.isEquipped(socketIndex, plugHash),
            available: state.isAvailable(socketIndex, plugHash),
            selectable: state.isSelectable(socketIndex, plugHash),
            onTap: () => bloc.toggleSelection(socketIndex, plugHash),
          );
        },
        expectedCrossAxisSize: PerkIconWidget.maxIconSize,
        initialFocus: initialFocus,
      ),
    );
  }

  Widget buildSockets(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final sockets = state.socketsForCategory(socketCategory);
    if (sockets == null) return Container();
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: sockets.map((e) => Flexible(child: buildSocket(context, e))).toList(),
      ),
    );
  }

  Widget buildSocket(BuildContext context, PlugSocket socket) {
    final state = context.watch<SocketControllerBloc>();
    final bloc = context.read<SocketControllerBloc>();
    final itemHash = state.itemHash;
    if (itemHash == null) return Container();
    final equippedPlugHash = state.equippedPlugHashForSocket(socket.index);
    final isSocketSelected = state.selectedSocketIndex == socket.index;
    final selectedPlugHash = state.selectedPlugHashForSocket(socket.index);
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSocketSelected ? context.theme.surfaceLayers.layer1 : Colors.transparent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
          ),
          padding: EdgeInsets.all(8),
          child: Container(
            constraints: BoxConstraints(maxWidth: PerkIconWidget.maxIconSize, maxHeight: PerkIconWidget.maxIconSize),
            child:
                equippedPlugHash != null && equippedPlugHash != 0
                    ? ModIconWidget(
                      equippedPlugHash,
                      selected: false,
                      equipped: isSocketSelected,
                      available: state.isAvailable(socket.index, equippedPlugHash),
                      selectable: state.isSelectable(socket.index, equippedPlugHash),
                      onTap: () => bloc.toggleSocketSelection(socket.index),
                    )
                    : Container(
                      color: context.theme.onSurfaceLayers,
                      padding: EdgeInsets.all(.5),
                      child: Material(
                        color: context.theme.surfaceLayers.layer1,
                        child: InkWell(
                          onTap: () => bloc.toggleSocketSelection(socket.index),
                        ),
                      ),
                    ),
          ),
        ),
        if (selectedPlugHash != null)
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
      ],
    );
  }

  Widget buildBars(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final total = state.availableEnergyCapacity;
    final used = state.usedEnergyCapacity;
    final maxAvailable = [total?.equipped ?? 0, total?.selected ?? 0, 10].reduce(max);
    return PingPongAnimationBuilder(
      (controller) => Container(
        child: Row(
          children: List.generate(
            maxAvailable,
            (index) => Expanded(child: buildEnergyPiece(context, index, total, used, controller.value)),
          ),
        ),
      ),
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
    BuildContext context,
    int index,
    StatValues? available,
    StatValues? used,
    double animationValue,
  ) {
    final theme = context.theme;
    final maxAvailable = max(available?.equipped ?? 0, available?.selected ?? 0);
    final maxUsed = max(used?.equipped ?? 0, used?.selected ?? 0);
    final isAvailable = index < maxAvailable;
    final isUsed = index < maxUsed;
    if (isAvailable) {
      return Container(
        height: 10,
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
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
        color:
            isUsed
                ? theme.errorLayers.withValues(alpha: .8)
                : context.theme.onSurfaceLayers.layer0.withValues(alpha: .5),
      ),
    );
  }
}
