import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class CategoryBreadcrumbWidget extends StatelessWidget implements PreferredSizeWidget {
  final List<int> categoryHashes;

  const CategoryBreadcrumbWidget({
    Key? key,
    required this.categoryHashes,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(32);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(height: 32),
        child: Material(
            color: context.theme.secondarySurfaceLayers.layer2,
            elevation: 0,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                        children: categoryHashes
                            .mapIndexed<Widget>((index, hash) => Row(children: [
                                  ManifestText<DestinyPresentationNodeDefinition>(hash),
                                  if (index < categoryHashes.length - 1) Text(' // ')
                                ]))
                            .toList())))));
  }
}
