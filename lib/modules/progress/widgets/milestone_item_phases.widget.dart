import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:provider/provider.dart';

class MilestoneItemPhasesWidget extends StatelessWidget {
  final List<DestinyMilestoneChallengeActivityPhase> definitionPhases;
  final List<DestinyMilestoneActivityPhase>? profilePhases;

  const MilestoneItemPhasesWidget({Key? key, required this.definitionPhases, this.profilePhases}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phases = definitionPhases;
    final finishedPhases = profilePhases //
        ?.map((e) => (e.complete ?? false) ? e.phaseHash : null)
        .whereType<int>()
        .toSet();
    return Container(
      margin: EdgeInsets.only(top: 8),
      height: 40,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          controller: ScrollController(keepScrollOffset: false, initialScrollOffset: 0),
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Container(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                children: phases.mapIndexed(
                  (index, element) {
                    final phaseHash = element.phaseHash;
                    final completed = finishedPhases?.contains(phaseHash) ?? false;
                    return Expanded(
                        child: buildPhase(
                      context,
                      completed: completed,
                      phaseHash: phaseHash,
                      index: index,
                    ));
                  },
                ).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPhase(BuildContext context, {bool completed = false, required int? phaseHash, required int index}) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: completed ? context.theme.secondarySurfaceLayers.layer1 : context.theme.surfaceLayers.layer2,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        getPhaseName(context, phaseHash, index),
        textAlign: TextAlign.center,
        style: context.textTheme.button.copyWith(
          color: completed ? context.theme.upgradeLayers.layer1 : context.theme.onSurfaceLayers.layer3,
        ),
      ),
    );
  }

  String getPhaseName(BuildContext context, int? phaseHash, int index) {
    final name = context.watch<LittleLightDataBloc>().gameData?.raidPhases?["$phaseHash"];
    if (name != null) return name.translate(context).split(" ").join("\n");
    return "Phase {phase}".translate(context, replace: {"phase": "${index + 1}"});
  }
}
