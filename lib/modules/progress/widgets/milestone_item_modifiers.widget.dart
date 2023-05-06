import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/progress/widgets/milestone_item_info_box.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class MilestoneItemModifiersWidget extends StatelessWidget {
  final List<int> modifierHashes;
  final VoidCallback onTap;

  const MilestoneItemModifiersWidget(this.modifierHashes, {Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MilestoneItemInfoBoxWidget(
      title: Text(
        "Modifiers".translate(context).toUpperCase(),
        style: context.textTheme.button,
      ),
      content: Row(
        children: modifierHashes //
            .map((hash) => buildModifier(context, hash))
            .whereType<Widget>()
            .toList(),
      ),
      onTap: onTap,
    );
  }

  Widget? buildModifier(BuildContext context, int? modifierHash) {
    final def = context.definition<DestinyActivityModifierDefinition>(modifierHash);
    final hasIcon = def?.displayProperties?.hasIcon ?? false;
    if (!hasIcon) return null;
    return Container(
      width: 24,
      height: 24,
      child: ManifestImageWidget<DestinyActivityModifierDefinition>(modifierHash),
      margin: EdgeInsets.only(right: 4),
    );
  }
}
