import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/tags/tag_pill.widget.dart';

typedef void OnRemoveTag(ItemNotesTag tag);

class DetailsItemTagsWidget extends StatelessWidget {
  final VoidCallback? onAddTap;
  final OnRemoveTag? onRemoveTag;
  final List<ItemNotesTag>? tags;

  const DetailsItemTagsWidget({
    Key? key,
    this.onAddTap,
    this.onRemoveTag,
    List<ItemNotesTag>? this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Item Tags".translate(context).toUpperCase()),
          persistenceID: 'item tags',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Wrap(
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        runSpacing: 4,
        spacing: 4,
        children: [
          ...buildTags(context),
          buildAddTagButton(context),
        ],
      ),
    );
  }

  List<Widget> buildTags(BuildContext context) {
    final tags = this.tags;
    if (tags == null) return [];
    return tags
        .map((t) => TagPillWidget.fromTag(
              t,
              onRemove: () => onRemoveTag?.call(t),
            ))
        .toList();
  }

  Widget buildAddTagButton(BuildContext context) => TagPillWidget(
        icon: FontAwesomeIcons.circlePlus,
        tagName: "Add Tag".translate(context),
        background: context.theme.primaryLayers.layer0,
        foreground: context.theme.onSurfaceLayers.layer0,
        onTap: onAddTap,
      );
}
