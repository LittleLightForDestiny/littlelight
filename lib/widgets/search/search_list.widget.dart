// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/item_list/items/search_item_wrapper.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';
import 'package:little_light/widgets/search/search.controller.dart';

class SearchListWidget extends StatefulWidget {
  final SearchController controller;

  SearchListWidget({Key key, this.controller}) : super(key: key);

  @override
  SearchListWidgetState createState() => SearchListWidgetState();
}

class SearchListWidgetState<T extends SearchListWidget> extends State<T> {
  bool loading = true;
  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  @override
  void dispose() {
    widget.controller.removeListener(update);
    super.dispose();
  }

  void asyncInit() async {
    await Future.delayed(Duration.zero);
    await Future.delayed(ModalRoute.of(context).transitionDuration);
    widget.controller.addListener(update);
    setState(() {
      loading = false;
    });
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.filtered == null || loading) {
      return LoadingAnimWidget();
    }
    return MultiSectionScrollView(
      [
        SliverSection(
            itemHeight: 96,
            itemsPerRow: MediaQueryHelper(context).responsiveValue(1, tablet: 2, laptop: 3),
            itemCount: widget.controller.filtered.length,
            itemBuilder: (context, index) => getItem(context, index))
      ],
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      padding: EdgeInsets.all(4),
    );
  }

  Widget getItem(BuildContext context, int index) {
    var item = widget.controller.filtered[index];
    return SearchItemWrapperWidget(item.item, null,
        characterId: item.ownerId, key: Key("item_${item.item.itemInstanceId}_${item.item.itemHash}"));
  }

  // StaggeredGridTile getTileBuilder(int index) {
  //   var item = widget.controller.filtered[index];
  //   if(InventoryBucket.pursuitBucketHashes.contains(item.item.bucketHash)){
  //     return StaggeredGridTile.extent(crossAxisCellCount:6, mainAxisExtent:150);
  //   }
  //   return StaggeredGridTile.extent(crossAxisCellCount:6, mainAxisExtent:96);
  // }
}
