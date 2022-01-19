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
  SearchListWidgetState createState() => new SearchListWidgetState();
}

class SearchListWidgetState<T extends SearchListWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(update);
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.filtered == null) {
      return LoadingAnimWidget();
    }
    bool isTablet = MediaQueryHelper(context).tabletOrBigger;
    bool isDesktop = MediaQueryHelper(context).isDesktop;
    return MultiSectionScrollView([
      SliverSection(
        itemHeight: 96,
        itemsPerRow: isDesktop ? 3 : isTablet ? 2 : 1,
        itemCount: widget.controller.filtered.length,
        itemBuilder: (context, index)=>getItem(context, index))
    ],
    crossAxisSpacing: 2,
    mainAxisSpacing: 2,
    
    );
  }

  Widget getItem(BuildContext context, int index) {
    var item = widget.controller.filtered[index];
    return SearchItemWrapperWidget(item.item, null,
        characterId: item.ownerId,
        key: Key("item_${item.item.itemInstanceId}_${item.item.itemHash}"));
  }

  // StaggeredGridTile getTileBuilder(int index) {
  //   var item = widget.controller.filtered[index];
  //   if(InventoryBucket.pursuitBucketHashes.contains(item.item.bucketHash)){
  //     return StaggeredGridTile.extent(crossAxisCellCount:6, mainAxisExtent:150);  
  //   }
  //   return StaggeredGridTile.extent(crossAxisCellCount:6, mainAxisExtent:96);
  // }
}
