import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/modules/triumphs/widgets/character_info_container.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/objectives/objective.widget.dart';

class DetailsRecordObjectivesWidget extends StatelessWidget {
  final int recordHash;
  final RecordProgressData? progress;
  final Map<String, DestinyCharacterInfo>? characters;

  const DetailsRecordObjectivesWidget(
    this.recordHash, {
    this.progress,
    this.characters,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(recordHash);
    final objectiveHashes = definition?.objectiveHashes;
    if (objectiveHashes == null) return Container();
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Objectives".translate(context).toUpperCase()),
          persistenceID: 'record objectives',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(recordHash);
    final scope = definition?.scope ?? DestinyScope.Profile;
    if (progress == null || scope == DestinyScope.Profile) {
      return buildSingleProgress(context, record: progress?.profile);
    }
    final charactersProgress = progress?.characters.entries.where((element) => element.value != null);
    if (charactersProgress == null || charactersProgress.isEmpty) {
      return buildSingleProgress(context, record: progress?.profile);
    }
    return Column(
      children: charactersProgress
          .map((e) => buildSingleProgress(
                context,
                record: e.value,
                characterId: e.key,
              ))
          .toList(),
    );
  }

  Widget buildSingleProgress(BuildContext context, {DestinyRecordComponent? record, String? characterId}) {
    final character = characters?[characterId];
    if (character == null)
      return buildProgressInfo(
        context,
        record,
      );
    return CharacterInfoContainerWidget(
      buildProgressInfo(context, record),
      character: character,
    );
  }

  Widget buildProgressInfo(BuildContext context, DestinyRecordComponent? progressRecord) {
    final definition = context.definition<DestinyRecordDefinition>(recordHash);
    final objectiveHashes = definition?.objectiveHashes;
    if (objectiveHashes == null) return Container();
    return Column(
      children: objectiveHashes
          .mapIndexed((index, progressHash) => ObjectiveWidget(
                progressHash,
                objective: progressRecord?.objectives?[index],
                placeholder: definition?.displayProperties?.name,
              ))
          .toList(),
    );
  }
}
