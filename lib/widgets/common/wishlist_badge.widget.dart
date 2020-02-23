import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/utils/wishlists_data.dart';

class WishlistBadgeWidget extends StatelessWidget {
  final Set<WishlistTag> tags;
  final double size;

  const WishlistBadgeWidget({this.tags, this.size = 24});

  @override
  Widget build(BuildContext context) {
    List<Widget> badges = List();
    if(tags.contains(WishlistTag.PVE)){
      badges.add(buildBadge(context, WishlistTag.PVE));
    }
    if(tags.contains(WishlistTag.PVP)){
      badges.add(buildBadge(context, WishlistTag.PVP));
    }
    if(tags.contains(WishlistTag.Bungie)){
      badges.add(buildBadge(context, WishlistTag.Bungie));
    }
    if(badges.length > 0){
      return Row(children: badges,);
    }
    if(tags.length == 0){
      return buildBadge(context, null);
    }
    if(tags.contains(WishlistTag.Trash)){
      return buildBadge(context, WishlistTag.Trash);
    }
    return Container();
  }

  Widget buildBadge(BuildContext context, WishlistTag tag) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        height:size,
        child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: WishlistsData.getBgColor(tag), borderRadius: BorderRadius.circular(4)),
              child: WishlistsData.getIcon(tag, size),
            )));
  }
}
