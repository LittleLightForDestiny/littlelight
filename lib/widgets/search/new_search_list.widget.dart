import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/item_list/items/search_item_wrapper.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';

class NewSearchListWidget extends StatefulWidget {
  final ProfileService profile = ProfileService();
  final SearchController controller;

  NewSearchListWidget({Key key, this.controller}) : super(key: key);
  final NotificationService broadcaster = new NotificationService();

  @override
  NewSearchListWidgetState createState() => new NewSearchListWidgetState();
}

class NewSearchListWidgetState<T extends NewSearchListWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(update);
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
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(4)
          .copyWith(bottom: MediaQuery.of(context).padding.bottom),
      crossAxisCount: isDesktop ? 24 : isTablet ? 12 : 6,
      itemCount: widget.controller.filtered.length,
      itemBuilder: getItem,
      staggeredTileBuilder: getTileBuilder,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  Widget getItem(BuildContext context, int index) {
    var item = widget.controller.filtered[index];
    return SearchItemWrapperWidget(item.item, null,
        characterId: item.ownerId,
        key: Key("item_${item.item.itemInstanceId}_${item.item.itemHash}"));
  }

  StaggeredTile getTileBuilder(int index) {
    return StaggeredTile.extent(6, 96);
  }
}
