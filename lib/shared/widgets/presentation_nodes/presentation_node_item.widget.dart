import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:little_light/shared/widgets/presentation_nodes/seal_info.widget.dart';
import 'package:little_light/shared/widgets/ui/center_icon_workaround.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

extension on BuildContext {
  Color get inProgressColor => theme.onSurfaceLayers.layer0;
  Color get completedColor => theme.achievementLayers.layer2;
}

class PresentationNodeItemWidget extends StatelessWidget {
  final int? presentationNodeHash;
  final VoidCallback? onTap;
  final PresentationNodeProgressData? progress;
  final Map<String, DestinyCharacterInfo>? characters;

  const PresentationNodeItemWidget(
    this.presentationNodeHash, {
    Key? key,
    this.onTap,
    this.progress,
    this.characters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyPresentationNodeDefinition>(presentationNodeHash);
    final completed = progress?.getProgress(definition?.scope)?.isComplete ?? false;
    final color = completed ? context.completedColor : context.inProgressColor;
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(.6), width: 1),
            gradient: LinearGradient(begin: const Alignment(0, 0), end: const Alignment(1, 2), colors: [
              color.withOpacity(.05),
              color.withOpacity(.1),
              color.withOpacity(.03),
              color.withOpacity(.1)
            ])),
        child: Stack(children: [
          Row(children: buildContent(context, definition)),
          Positioned(bottom: 0, left: 0, right: 0, child: buildProgressBar(context)),
          MaterialButton(child: Container(), onPressed: onTap)
        ]));
  }

  Widget buildProgressBar(BuildContext context) {
    final definition = context.definition<DestinyPresentationNodeDefinition>(presentationNodeHash);
    final completionValue = progress?.getProgress(definition?.scope)?.completionValue ?? 0;
    if (completionValue == 0) return Container();
    final completed = progress?.getProgress(definition?.scope)?.isComplete ?? false;
    final color = completed ? context.completedColor : context.inProgressColor;
    final progressValue = progress?.getProgress(definition?.scope)?.progressValue ?? 0;
    return Container(
      height: 4,
      color: color.withOpacity(.4),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
          widthFactor: progressValue / completionValue, child: Container(color: color.withOpacity(.7))),
    );
  }

  List<Widget> buildContent(BuildContext context, DestinyPresentationNodeDefinition? definition) {
    return [
      definition?.displayProperties?.hasIcon == true
          ? AspectRatio(
              aspectRatio: 1,
              child: definition?.displayProperties?.icon == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8),
                      child: QueuedNetworkImage(
                        imageUrl: BungieApiService.url(definition?.displayProperties?.icon)!,
                      )))
          : Container(width: 20),
      buildName(context),
      Container(
        padding: EdgeInsets.only(right: 8),
        child: buildCount(context),
      ),
    ];
  }

  Widget buildCount(BuildContext context) {
    final definition = context.definition<DestinyPresentationNodeDefinition>(presentationNodeHash);
    if (definition?.scope == DestinyScope.Profile) {
      return buildSingleCount(context, progress?.profile);
    }
    final progressCharacters = progress?.characters;
    if (definition?.scope == DestinyScope.Character && progressCharacters != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children:
            progressCharacters.entries.map((e) => buildSingleCount(context, e.value, characterId: e.key)).toList(),
      );
    }
    return Container();
  }

  Widget buildSingleCount(BuildContext context, DestinyPresentationNodeComponent? progress, {String? characterId}) {
    final completed = progress?.isComplete ?? false;
    final color = completed ? context.completedColor : context.inProgressColor;
    final character = characters?[characterId];
    final completionValue = progress?.completionValue ?? 0;
    final icon = character?.character.classType?.icon;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1),
      child: Stack(children: [
        if (character != null)
          Positioned.fill(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: ManifestImageWidget<DestinyInventoryItemDefinition>(
              character.character.emblemHash,
              urlExtractor: (def) => def.secondarySpecial,
              fit: BoxFit.cover,
            ),
          )),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Row(children: [
            if (icon != null)
              Container(
                width: 16,
                height: 16,
                margin: EdgeInsets.only(right: 4),
                child: CenterIconWorkaround(icon, size: 16, color: color),
              ),
            (completionValue) > 0
                ? Text(
                    "${progress?.progressValue}/${progress?.completionValue}",
                    style: context.textTheme.highlight.copyWith(color: color),
                  )
                : Container()
          ]),
        )
      ]),
    );
  }

  Widget buildName(BuildContext context) {
    final definition = context.definition<DestinyPresentationNodeDefinition>(presentationNodeHash);
    final completed = progress?.getProgress(definition?.scope)?.isComplete ?? false;
    final color = completed ? context.completedColor : context.inProgressColor;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              definition?.displayProperties?.name ?? "",
              softWrap: true,
              style: context.textTheme.highlight.copyWith(color: color),
            ),
            buildTitleInfo(context),
          ].whereType<Widget>().toList(),
        ),
      ),
    );
  }

  Widget? buildTitleInfo(BuildContext context) {
    final definition = context.definition<DestinyPresentationNodeDefinition>(presentationNodeHash);
    final completionRecordHash = definition?.completionRecordHash;
    if (completionRecordHash == null) return null;
    return SealInfoWidget(
      completionRecordHash,
      progress: progress,
    );
  }
}
