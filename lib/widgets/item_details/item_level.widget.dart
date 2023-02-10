import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/mixins/deepsight_helper.mixin.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/common/objective.widget.dart';

const levelProgressionHash = 2899837482;
const weaponLevelHash = 3077315735;
const craftingDateHash = 3947811849;

extension on List {
  elementAtOrNull(int index) {
    try {
      return this[index];
    } catch (e) {}
    return null;
  }
}

class ItemLevelWidget extends StatelessWidget with ProfileConsumer, DeepSightHelper {
  final DestinyItemComponent item;

  ItemLevelWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final instanceID = item.itemInstanceId;
    if (instanceID == null) return Container();
    if (!isShapedWeaponOrDeepsight(instanceID)) return Container();
    return Container(child: buildPlugObjectives(context, instanceID));
  }

  Widget? buildPlugObjectives(BuildContext context, String itemInstanceID) {
    final shapedWeaponHash = getShapedWeaponHash(itemInstanceID);
    if (shapedWeaponHash != null) return buildShapedWeaponProgress(context, shapedWeaponHash);
    final deepSightHash = getDeepSightHash(itemInstanceID);
    if (deepSightHash != null) return buildDeepSightResonance(context, deepSightHash);
    return null;
  }

  Widget? buildDeepSightResonance(BuildContext context, int hash) {
    final objectives = getDeepSightObjectives(item.itemInstanceId!);
    final objective = objectives?.firstOrNull;
    if (objective == null) return null;
    return Column(children: [
      buildObjectiveTitle(context, hash),
      buildProgressBar(context, objective),
    ]);
  }

  Widget? buildShapedWeaponProgress(BuildContext context, int hash) {
    final objectives = getShapedWeaponObjectives(item.itemInstanceId!);
    if (objectives == null) return null;
    final levelProgression = objectives.elementAtOrNull(0);
    final weaponLevel = objectives.elementAtOrNull(1);
    final craftingDate = objectives.elementAtOrNull(2);
    if (levelProgression == null || weaponLevel == null || craftingDate == null) return null;
    return Column(children: [
      buildObjectiveTitle(context, hash),
      buildProgressBar(context, weaponLevel),
      buildProgressBar(context, levelProgression),
      buildProgressBar(context, craftingDate),
    ]);
  }

  Widget buildProgressBar(BuildContext context, DestinyObjectiveProgress objective) {
    return Container(
        padding: const EdgeInsets.only(top: 8),
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
