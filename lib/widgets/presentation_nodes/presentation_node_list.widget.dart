import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/presentation_nodes/presentation_node_item.widget.dart';

typedef PresentationNodeTap = void Function(int presentationNodeHash);

class PresentationNodeListWidget extends StatelessWidget {
  final DestinyPresentationNodeDefinition node;
  final PresentationNodeTap? onItemTap;

  const PresentationNodeListWidget({Key? key, required this.node, this.onItemTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiSectionScrollView(
      [
        SliverSection(
          itemsPerRow: MediaQueryHelper(context).responsiveValue(1, tablet: 2, desktop: 3),
          itemCount: node.children?.presentationNodes?.length ?? 0,
          itemHeight: 80,
          itemBuilder: (context, index) => buildItem(context, index),
        )
      ],
      padding: const EdgeInsets.all(4) + MediaQuery.of(context).viewPadding,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    );
  }

  Widget buildItem(BuildContext context, int index) {
    final childNode = node.children?.presentationNodes?[index];
    if (childNode == null) return Container();
    return PresentationNodeItemWidget(
        onPressed: () => onItemTap?.call(childNode.presentationNodeHash!), hash: childNode.presentationNodeHash);
  }
}
