import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';

typedef PresentationNodeBuilder = Widget Function(BuildContext context, DestinyPresentationNodeChildEntry entry);
typedef CollectibleBuilder = Widget Function(BuildContext context, DestinyPresentationNodeCollectibleChildEntry entry);

const _itemHeight = 96.0;

class PresentationNodeListWidget extends StatelessWidget {
  final int? presentationNodeHash;
  final PresentationNodeBuilder? presentationNodeBuilder;
  final CollectibleBuilder? collectibleBuilder;
  final EdgeInsets? padding;
  const PresentationNodeListWidget(
    this.presentationNodeHash, {
    this.presentationNodeBuilder,
    this.collectibleBuilder,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemsPerRow = MediaQueryHelper(context).responsiveValue(1, tablet: 2, desktop: 3);
    final def = context.definition<DestinyPresentationNodeDefinition>(presentationNodeHash);
    final presentationNodeBuilder = this.presentationNodeBuilder;
    final collectibleBuilder = this.collectibleBuilder;
    final presentationNodes = def?.children?.presentationNodes //
        ?.whereType<DestinyPresentationNodeChildEntry>()
        .toList();
    final collectibles = def?.children?.collectibles //
        ?.whereType<DestinyPresentationNodeCollectibleChildEntry>()
        .toList();
    return MultiSectionScrollView(
      [
        if (presentationNodeBuilder != null && presentationNodes != null)
          SliverSection(
            itemsPerRow: itemsPerRow,
            itemCount: presentationNodes.length,
            itemHeight: _itemHeight,
            itemBuilder: (context, index) => presentationNodeBuilder(context, presentationNodes[index]),
          ),
        if (collectibleBuilder != null && collectibles != null)
          SliverSection(
            itemsPerRow: itemsPerRow,
            itemCount: collectibles.length,
            itemHeight: _itemHeight,
            itemBuilder: (context, index) => collectibleBuilder(context, collectibles[index]),
          )
      ],
      padding: padding,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    );
  }
}
