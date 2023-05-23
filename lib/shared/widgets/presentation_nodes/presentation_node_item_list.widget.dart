import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';

typedef PresentationNodeBuilder = Widget Function(BuildContext context, DestinyPresentationNodeChildEntry entry);
typedef CollectibleBuilder = Widget Function(BuildContext context, DestinyPresentationNodeCollectibleChildEntry entry);
typedef RecordBuilder = Widget Function(BuildContext context, DestinyPresentationNodeRecordChildEntry entry);

const _itemHeight = 96.0;

class PresentationNodeListWidget extends StatelessWidget {
  final int? presentationNodeHash;
  final List<DestinyPresentationNodeCollectibleChildEntry>? collectibles;
  final List<DestinyPresentationNodeChildEntry>? childNodes;
  final List<DestinyPresentationNodeRecordChildEntry>? records;
  final PresentationNodeBuilder? presentationNodeBuilder;
  final CollectibleBuilder? collectibleBuilder;
  final RecordBuilder? recordBuilder;
  final EdgeInsets? padding;

  const PresentationNodeListWidget(
    this.presentationNodeHash, {
    this.childNodes,
    this.collectibles,
    this.records,
    this.presentationNodeBuilder,
    this.collectibleBuilder,
    this.recordBuilder,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemsPerRow = MediaQueryHelper(context).responsiveValue(1, tablet: 2, desktop: 3);
    final def = context.definition<DestinyPresentationNodeDefinition>(presentationNodeHash);
    final presentationNodeBuilder = this.presentationNodeBuilder;
    final collectibleBuilder = this.collectibleBuilder;
    final recordBuilder = this.recordBuilder;
    final presentationNodes = this.childNodes ??
        def?.children?.presentationNodes //
            ?.whereType<DestinyPresentationNodeChildEntry>()
            .toList();
    final collectibles = this.collectibles ??
        def?.children?.collectibles //
            ?.whereType<DestinyPresentationNodeCollectibleChildEntry>()
            .toList();
    final records = this.records ??
        def?.children?.records //
            ?.whereType<DestinyPresentationNodeRecordChildEntry>()
            .toList();
    return MultiSectionScrollView(
      [
        if (presentationNodeBuilder != null && presentationNodes != null)
          FixedHeightScrollSection(
            _itemHeight,
            itemsPerRow: itemsPerRow,
            itemCount: presentationNodes.length,
            itemBuilder: (context, index) => presentationNodeBuilder(context, presentationNodes[index]),
          ),
        if (collectibleBuilder != null && collectibles != null)
          FixedHeightScrollSection(
            _itemHeight,
            itemsPerRow: itemsPerRow,
            itemCount: collectibles.length,
            itemBuilder: (context, index) => collectibleBuilder(context, collectibles[index]),
          ),
        if (recordBuilder != null && records != null)
          FixedHeightScrollSection(
            128.0,
            itemsPerRow: itemsPerRow,
            itemCount: records.length,
            itemBuilder: (context, index) => recordBuilder(context, records[index]),
          )
      ],
      padding: padding,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    );
  }
}
