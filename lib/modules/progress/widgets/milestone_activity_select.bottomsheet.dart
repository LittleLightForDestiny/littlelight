import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/shared/widgets/modals/bottom_sheet.base.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class MilestoneActivitySelectBottomSheet extends BaseItemSelectionBottomSheet<int> {
  final List<int> activityHashes;
  MilestoneActivitySelectBottomSheet(this.activityHashes);
  @override
  Widget? buildHeader(BuildContext context) {
    return Text("Select an activity".translate(context).toUpperCase());
  }

  @override
  Widget? buildItemLabel(BuildContext context, int index) {
    final hash = activityHashes.elementAtOrNull(index);
    if (hash == null) return null;
    return ManifestText<DestinyActivityDefinition>(
      hash,
      uppercase: true,
    );
  }

  @override
  int? indexToValue(int index) {
    return activityHashes[index];
  }

  @override
  int? get itemCount => activityHashes.length;
}
