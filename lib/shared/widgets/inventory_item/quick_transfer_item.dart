import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:provider/provider.dart';

class QuickTransferItem extends StatelessWidget {
  final double borderWidth;
  final int bucketHash;
  final String characterId;
  const QuickTransferItem({
    Key? key,
    this.borderWidth = 2,
    required this.bucketHash,
    required this.characterId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildBackground(context),
        buildInkwell(context),
      ],
    );
  }

  Widget buildBackground(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        border: Border.all(
          width: borderWidth,
          color: context.theme.onSurfaceLayers.layer3,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.add_circle_outline,
          color: context.theme.onSurfaceLayers.layer3,
        ),
      ),
    );
  }

  Widget buildInkwell(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final interaction = context.read<ItemInteractionHandlerBloc>();
          interaction.onEmptySlotTap?.call(bucketHash, characterId);
        },
      ),
    );
  }
}
