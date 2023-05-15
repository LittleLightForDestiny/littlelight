import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:provider/provider.dart';

class DetailsApplyPlugButtonWidget extends StatelessWidget {
  final int? socketIndex;
  final int plugHash;

  const DetailsApplyPlugButtonWidget({
    required this.plugHash,
    this.socketIndex,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final canApply = state.canApply(socketIndex, plugHash);
    final isAvaialble = state.isAvailable(socketIndex, plugHash);
    if (!canApply) return Container();
    final isPlugBusy = state.isBusy;
    final disabled = isPlugBusy || !isAvaialble;
    final plugDef = context.definition<DestinyInventoryItemDefinition>(plugHash);
    return Opacity(
      opacity: disabled ? .5 : 1,
      child: Container(
        margin: EdgeInsets.only(top: 4),
        padding: EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: !disabled
              ? () {
                  context.read<SocketControllerBloc>().applySelectedPlug();
                }
              : null,
          child: DefaultLoadingShimmer(
            enabled: isPlugBusy,
            child: Text(
              "Apply {modType}".translate(
                context,
                replace: {"modType": plugDef?.itemTypeDisplayName?.toLowerCase() ?? ""},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
