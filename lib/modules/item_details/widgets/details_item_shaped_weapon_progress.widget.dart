import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/objectives/objective.widget.dart';

class DetailsItemCraftedProgressWidget extends StatelessWidget {
  final ItemDetailsBloc state;

  const DetailsItemCraftedProgressWidget({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCrafted = state.item?.state?.contains(ItemState.Crafted) ?? false;
    if (!isCrafted) return Container();
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Crafting progress".translate(context).toUpperCase()),
          persistenceID: 'crafting progress info',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    final objectives = state.craftedObjectives;
    if (objectives == null) return Container();
    final levelProgression = objectives.elementAtOrNull(0);
    final weaponLevel = objectives.elementAtOrNull(1);
    final craftingDate = objectives.elementAtOrNull(2);
    if (levelProgression == null && weaponLevel == null && craftingDate == null) return Container();
    return Column(
        children: [
      buildProgressBar(context, weaponLevel),
      buildProgressBar(context, levelProgression),
      buildProgressBar(context, craftingDate),
    ].whereType<Widget>().toList());
  }

  Widget? buildProgressBar(BuildContext context, DestinyObjectiveProgress? objective) {
    final objectiveHash = objective?.objectiveHash;
    if (objectiveHash == null) return null;
    return Container(
        padding: const EdgeInsets.only(top: 8),
        child: ObjectiveWidget(
          objectiveHash,
          objective: objective,
          barColor: context.theme.highlightedObjectiveLayers,
        ));
  }
}
