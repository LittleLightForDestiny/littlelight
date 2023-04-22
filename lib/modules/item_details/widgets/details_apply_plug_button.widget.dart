import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';

class DetailsApplyPlugButtonWidget extends StatelessWidget {
  final int plugHash;

  const DetailsApplyPlugButtonWidget(
    this.plugHash,
  );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final canApply = state.canApplySelectedPlug();
    if (!canApply) return Container();
    final isPlugBusy = state.isBusy;
    final plugDef = context.definition<DestinyInventoryItemDefinition>(plugHash);
    return Opacity(
      opacity: isPlugBusy ? .5 : 1,
      child: Container(
        margin: EdgeInsets.only(top: 4),
        padding: EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: !isPlugBusy
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
