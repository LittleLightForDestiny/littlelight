import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

const _recordIconSize = 56.0;

class DetailsRecordDescriptionWidget extends StatelessWidget {
  final int recordHash;

  DetailsRecordDescriptionWidget(this.recordHash);

  Widget build(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(recordHash);
    final isLore = definition?.loreHash != null;
    if (isLore) return buildLoreCover(context);

    final description = definition?.displayProperties?.description;
    if (description == null || description.isEmpty) return Container();
    return Container(
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildIcon(context),
            Expanded(child: buildBasicInfo(context)),
          ].whereType<Widget>().toList(),
        ));
  }

  Widget buildLoreCover(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 16),
            constraints: BoxConstraints(maxHeight: 256.0),
            child: ManifestImageWidget<DestinyRecordDefinition>(
              recordHash,
              urlExtractor: (def) {
                final frames = def.displayProperties?.iconSequences
                        ?.fold<List<String?>>([], (list, element) => [...list, ...(element.frames ?? [])]).reversed ??
                    [];
                return [
                  def.displayProperties?.highResIcon,
                  ...frames,
                  def.displayProperties?.icon,
                ].firstWhereOrNull((element) => element != null);
              },
            ),
          ),
          ManifestText<DestinyRecordDefinition>(
            recordHash,
            style: context.textTheme.largeTitle,
          ),
        ],
      ),
    );
  }

  Widget? buildIcon(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(this.recordHash);
    final hasIcon = (definition?.displayProperties?.hasIcon ?? false) && definition?.displayProperties?.icon != null;
    if (!hasIcon) return null;
    return Container(
        margin: EdgeInsets.all(4),
        width: _recordIconSize,
        height: _recordIconSize,
        child: ManifestImageWidget<DestinyRecordDefinition>(recordHash));
  }

  Widget buildBasicInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitleBar(context),
          Container(color: context.theme.onSurfaceLayers, height: 1),
          buildDescription(context),
        ],
      ),
    );
  }

  Widget buildTitleBar(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(this.recordHash);
    int? scoreValue = definition?.completionInfo?.scoreValue;
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
          child: Container(
              padding: const EdgeInsets.all(4),
              child: Text(
                definition?.displayProperties?.name ?? "",
                softWrap: true,
                style: context.textTheme.itemNameHighDensity,
              ))),
      Container(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Text(
            "${scoreValue}",
            style: context.textTheme.body,
          )),
    ]);
  }

  Widget buildDescription(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.0),
      child: ManifestText<DestinyRecordDefinition>(recordHash,
          textExtractor: (def) => def.displayProperties?.description ?? "",
          overflow: TextOverflow.fade,
          style: context.textTheme.body.copyWith(
            color: context.theme.onSurfaceLayers,
          )),
    );
  }
}
