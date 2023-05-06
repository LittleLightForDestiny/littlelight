import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/modals/base_list_bottom_sheet.base.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class MilestoneModifiersBottomSheet extends BaseListBottomSheet {
  final int activityHash;
  final List<int> modifierHashes;
  MilestoneModifiersBottomSheet(this.activityHash, this.modifierHashes);
  @override
  Widget? buildHeader(BuildContext context) {
    return ManifestText<DestinyActivityDefinition>(
      activityHash,
      textExtractor: (def) {
        final name = def.displayProperties?.name;
        if (name == null) return "Modifiers".translate(context, useReadContext: true).toUpperCase();
        return "{activityName} Modifiers"
            .translate(context, replace: {"activityName": name}, useReadContext: true)
            .toUpperCase();
      },
    );
  }

  @override
  Widget? buildItemLabel(BuildContext context, int index) {
    final hash = modifierHashes.elementAtOrNull(index);
    if (hash == null) return null;
    final def = context.definition<DestinyActivityModifierDefinition>(hash);
    final description = def?.displayProperties?.description;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (def?.displayProperties?.hasIcon ?? false)
            Container(
                width: 24,
                height: 24,
                margin: EdgeInsets.only(right: 8),
                child: ManifestImageWidget<DestinyActivityModifierDefinition>(hash)),
          Expanded(child: ManifestText<DestinyActivityModifierDefinition>(hash)),
        ],
      ),
      if (description != null)
        Container(
          padding: EdgeInsets.all(4),
          child: ManifestText<DestinyActivityModifierDefinition>(
            hash,
            textExtractor: (def) => def.displayProperties?.description?.replaceAll('\n\n', '\n'),
            style: context.textTheme.body,
          ),
        ),
    ]);
  }

  @override
  int? get itemCount => modifierHashes.length;
}
