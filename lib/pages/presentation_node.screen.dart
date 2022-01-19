import 'package:bungie_api/enums/destiny_presentation_screen_style.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/refresh_button.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/presentation_nodes/collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/metric_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/nested_collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_body.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';
import 'package:little_light/widgets/presentation_nodes/record_item.widget.dart';

class PresentationNodeScreen extends StatefulWidget {
  

  final int presentationNodeHash;
  final int depth;
  final PresentationNodeItemBuilder itemBuilder;
  final bool isCategorySet;
  PresentationNodeScreen(
      {this.presentationNodeHash,
      this.itemBuilder,
      this.isCategorySet = false,
      this.depth = 0});

  @override
  PresentationNodeScreenState createState() =>
      new PresentationNodeScreenState();
}

class PresentationNodeScreenState<T extends PresentationNodeScreen>
    extends State<T> with ManifestConsumer{
  DestinyPresentationNodeDefinition definition;
  @override
  void initState() {
    super.initState();

    if (definition == null && widget.presentationNodeHash != null) {
      loadDefinition();
    }
  }

  loadDefinition() async {
    definition = await manifest
        .getDefinition<DestinyPresentationNodeDefinition>(
            widget.presentationNodeHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(definition?.displayProperties?.name ?? "")),
        body: buildScaffoldBody(context));
  }

  Widget buildScaffoldBody(BuildContext context) {
    return Stack(children: [
      Column(children: [
        Expanded(child: buildBody(context)),
        SelectedItemsWidget(),
      ]),
      Positioned(
        right: 8,
        bottom: 8,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryVariant,
              borderRadius: BorderRadius.circular(18)),
          width: 36,
          height: 36,
          child: RefreshButtonWidget(),
        ),
      ),
    ]);
  }

  Widget buildBody(BuildContext context) {
    return PresentationNodeBodyWidget(
        isCategorySet: widget.isCategorySet ||
            definition?.screenStyle ==
                DestinyPresentationScreenStyle.CategorySets,
        presentationNodeHash: widget.presentationNodeHash,
        depth: widget.depth,
        itemBuilder: widget.itemBuilder,);
  }

  Widget itemBuilder(CollectionListItem item, int depth, bool isCategorySet) {
    switch (item.type) {
      case CollectionListItemType.presentationNode:
        return PresentationNodeItemWidget(
          hash: item.hash,
          depth: depth,
          onPressed: onPresentationNodePressed,
          isCategorySet: isCategorySet,
        );

      case CollectionListItemType.nestedCollectible:
        return NestedCollectibleItemWidget(hash: item.hash);

      case CollectionListItemType.collectible:
        return CollectibleItemWidget(hash: item.hash);

      case CollectionListItemType.record:
        return RecordItemWidget(
          hash: item.hash,
          key: Key("record_${item.hash}"),
        );

      case CollectionListItemType.metric:
        return MetricItemWidget(
          hash: item.hash,
          key: Key("metric_${item.hash}"),
        );

      default:
        return Container(color: Colors.red);
    }
  }

  // StaggeredGridTile tileBuilder(CollectionListItem item) {
  //   switch (item.type) {
  //     case CollectionListItemType.presentationNode:
  //       return StaggeredGridTile.extent(crossAxisCellCount:30, mainAxisExtent:92);

  //     case CollectionListItemType.nestedCollectible:
  //       if (MediaQueryHelper(context).tabletOrBigger) {
  //         return StaggeredGridTile.count(crossAxisCellCount:3, mainAxisCellCount:3);
  //       }
  //       return StaggeredGridTile.count(crossAxisCellCount:6, mainAxisCellCount:6);

  //     case CollectionListItemType.collectible:
  //       if (MediaQueryHelper(context).tabletOrBigger) {
  //         return StaggeredGridTile.extent(crossAxisCellCount:10, mainAxisExtent:96);
  //       }
  //       return StaggeredGridTile.extent(crossAxisCellCount:30, mainAxisExtent:96);

  //     case CollectionListItemType.record:
  //       if (MediaQueryHelper(context).tabletOrBigger) {
  //         return StaggeredGridTile.fit(crossAxisCellCount:10);
  //       }
  //       return StaggeredGridTile.fit(crossAxisCellCount:30);

  //     case CollectionListItemType.metric:
  //       if (MediaQueryHelper(context).tabletOrBigger) {
  //         return StaggeredGridTile.extent(crossAxisCellCount:10, mainAxisExtent:96);
  //       }
  //       return StaggeredGridTile.extent(crossAxisCellCount:30, mainAxisExtent:96);

  //     default:
  //       return StaggeredGridTile.count(crossAxisCellCount:30, mainAxisCellCount:7);
  //   }
  // }

  void onPresentationNodePressed(int hash, int depth, bool isCategorySet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PresentationNodeScreen(
            presentationNodeHash: hash,
            depth: depth + 1,
            itemBuilder: widget.itemBuilder ?? itemBuilder,
            isCategorySet: isCategorySet),
      ),
    );
  }
}
