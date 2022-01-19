import 'package:bungie_api/enums/destiny_presentation_screen_style.dart';
import 'package:bungie_api/models/destiny_presentation_node_child_entry.dart';
import 'package:bungie_api/models/destiny_presentation_node_collectible_child_entry.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:bungie_api/models/destiny_presentation_node_metric_child_entry.dart';
import 'package:bungie_api/models/destiny_presentation_node_record_child_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';

typedef StaggeredGridTile PresentationNodeTileBuilder(CollectionListItem item);
typedef Widget PresentationNodeItemBuilder(CollectionListItem item, int depth, bool isCategorySet);

class PresentationNodeListWidget extends StatefulWidget {
  final int presentationNodeHash;
  final PresentationNodeItemBuilder itemBuilder;
  final int depth;
  final bool isCategorySets;
  PresentationNodeListWidget({
    Key key,
    @required this.itemBuilder,
    this.isCategorySets = false,
    this.presentationNodeHash,
    this.depth = 0,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PresentationNodeListWidgetState();
  }
}

class PresentationNodeListWidgetState extends State<PresentationNodeListWidget> with ManifestConsumer {
  DestinyPresentationNodeDefinition definition;
  Map<int, DestinyPresentationNodeDefinition> _presentationNodeDefinitions;

  List<CollectionListItem> listIndex;

  @override
  void initState() {
    super.initState();
    if (widget.presentationNodeHash != null) {
      buildIndex();
    }
  }

  void buildIndex() async {
    definition = await manifest.getDefinition<DestinyPresentationNodeDefinition>(widget.presentationNodeHash);
    if (presentationNodes.length > 0) {
      List<int> hashes = presentationNodes.map((node) => node.presentationNodeHash).toList();
      _presentationNodeDefinitions = await manifest.getDefinitions<DestinyPresentationNodeDefinition>(hashes);
    }
    listIndex = [];
    presentationNodes.forEach((node) {
      listIndex.add(CollectionListItem(CollectionListItemType.presentationNode, node.presentationNodeHash));
      var def = _presentationNodeDefinitions[node.presentationNodeHash];
      if (widget.isCategorySets) {
        def?.children?.collectibles?.forEach((collectible) {
          listIndex.add(CollectionListItem(CollectionListItemType.nestedCollectible, collectible.collectibleHash));
        });
      }
    });
    collectibles.forEach((collectible) {
      listIndex.add(CollectionListItem(CollectionListItemType.collectible, collectible.collectibleHash));
    });

    records.forEach((record) {
      listIndex.add(CollectionListItem(CollectionListItemType.record, record.recordHash));
    });

    metrics.forEach((metric) {
      listIndex.add(CollectionListItem(CollectionListItemType.metric, metric.metricHash));
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (listIndex == null) return LoadingAnimWidget();
    return MultiSectionScrollView(
      [
        SliverSection(
          itemCount: listIndex?.length,
          itemHeight: itemHeight,
          itemBuilder: (context, index) => getItem(context, index),
        )
      ],
      padding: EdgeInsets.all(4),
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    );
  }

  double get itemHeight => 112;

  Widget getItem(BuildContext context, int index) {
    var item = listIndex[index];
    return widget.itemBuilder(item, widget.depth, this.isCategorySets);
  }

  bool get isCategorySets =>
      widget.isCategorySets || definition?.screenStyle == DestinyPresentationScreenStyle.CategorySets;

  List<DestinyPresentationNodeChildEntry> get presentationNodes => definition?.children?.presentationNodes;

  List<DestinyPresentationNodeCollectibleChildEntry> get collectibles => definition?.children?.collectibles;

  List<DestinyPresentationNodeRecordChildEntry> get records => definition?.children?.records;

  List<DestinyPresentationNodeMetricChildEntry> get metrics => definition?.children?.metrics;

  int get count => listIndex?.length ?? 0;

  ///TODO: remove tile builder
  // StaggeredGridTile getTileBuilder(int index) {
  //   var item = listIndex[index];
  //   return widget.tileBuilder(item);
  // }
}

enum CollectionListItemType { presentationNode, collectible, nestedCollectible, nestedRecord, record, metric }

class CollectionListItem {
  final CollectionListItemType type;
  final int hash;
  CollectionListItem(this.type, this.hash);
}
