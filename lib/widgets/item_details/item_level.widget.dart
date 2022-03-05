import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/common/objective.widget.dart';

const _deepSightResonanceHash = 2400712188;
const _calibrationProgressHash = 1162857131;

const _shapedWeaponProgressHash = 659359923;
const levelProgressionHash = 2899837482;
const weaponLevelHash = 3077315735;
const craftingDateHash = 3947811849;

class ItemLevelWidget extends StatelessWidget with ProfileConsumer, LanguageConsumer {
  final DestinyItemComponent item;

  const ItemLevelWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final instanceID = item.itemInstanceId;
    if (instanceID == null) return Container();
    final plugs = profile.getPlugObjectives(instanceID);
    if (plugs == null) return Container();

    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: plugs.entries
                .map<Widget?>((o) => buildPlugObjectives(
                      context,
                      int.parse(o.key),
                      o.value,
                    ))
                .whereType<Widget>()
                .map((w) => Container(padding: EdgeInsets.all(8), child: w))
                .toList()));
  }

  Widget? buildPlugObjectives(BuildContext context, int hash, List<DestinyObjectiveProgress> objectives) {
    if (hash == _deepSightResonanceHash) return buildDeepSightResonance(context, objectives);
    if (hash == _shapedWeaponProgressHash) return buildShapedWeaponProgress(context, objectives);
    return null;
  }

  Widget? buildDeepSightResonance(BuildContext context, List<DestinyObjectiveProgress> objectives) {
    final objective = objectives.firstWhereOrNull((o) => o.objectiveHash == _calibrationProgressHash);
    if (objective == null) return null;
    return Column(children: [
      buildObjectiveTitle(context, _deepSightResonanceHash),
      buildProgressBar(context, objective),
    ]);
  }

  Widget? buildShapedWeaponProgress(BuildContext context, List<DestinyObjectiveProgress> objectives) {
    final levelProgression = objectives.firstWhereOrNull((o) => o.objectiveHash == levelProgressionHash);
    final weaponLevel = objectives.firstWhereOrNull((o) => o.objectiveHash == weaponLevelHash);
    final craftingDate = objectives.firstWhereOrNull((o) => o.objectiveHash == craftingDateHash);
    if (levelProgression == null || weaponLevel == null || craftingDate == null) return null;
    return Column(children: [
      buildObjectiveTitle(context, _shapedWeaponProgressHash),
      buildProgressBar(context, weaponLevel),
      buildProgressBar(context, levelProgression),
      buildProgressBar(context, craftingDate),
    ]);
  }

  Widget buildProgressBar(BuildContext context, DestinyObjectiveProgress objective) {
    return Container(
        padding: EdgeInsets.only(top: 8),
        child: DefinitionProviderWidget<DestinyObjectiveDefinition>(
            objective.objectiveHash!,
            (def) => ObjectiveWidget(
                  omitCheckBox: true,
                  definition: def,
                  objective: objective,
                  barColor: LittleLightTheme.of(context).highlightedObjectiveLayers,
                )));
  }

  Widget buildObjectiveTitle(BuildContext context, int hash) {
    return HeaderWidget(
        child: ManifestText<DestinyInventoryItemDefinition>(
      hash,
      uppercase: true,
    ));
  }
}
