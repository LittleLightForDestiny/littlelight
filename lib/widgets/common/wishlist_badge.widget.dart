import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/widgets/icon_fonts/destiny_icons_icons.dart';

class WishlistBadgeWidget extends StatelessWidget {
  final Set<WishlistTag> tags;
  final double size;

  const WishlistBadgeWidget({this.tags, this.size = 24});

  @override
  Widget build(BuildContext context) {
    List<Widget> badges = List();
    if(tags.contains(WishlistTag.PVE)){
      badges.add(buildBadge(context, Colors.blue.shade800, Icon(DestinyIcons.vanguard, size:size*.9)));
    }
    if(tags.contains(WishlistTag.PVP)){
      badges.add(buildBadge(context, Colors.red.shade800, Icon(DestinyIcons.crucible, size:size*.9)));
    }
    if(tags.contains(WishlistTag.Bungie)){
      badges.add(buildBadge(context, Colors.black, Icon(DestinyIcons.bungie, size:size*.9,)));
    }
    if(badges.length > 0){
      return Row(children: badges,);
    }
    if(tags.length == 0){
      return buildBadge(context, Colors.amber.shade500, Container(
        padding:EdgeInsets.all(size*.1),
        child:Icon(Icons.star, size:size*.8,)),);
    }
    if(tags.contains(WishlistTag.Trash)){
      return buildBadge(context, Colors.lightGreen.shade500, Container(
        padding:EdgeInsets.all(size*.1),
        child:Image.asset(
                "assets/imgs/trash-roll-icon.png",
              )),);
    }
    return Container();
  }

  Widget buildBadge(BuildContext context, Color bgColor, Widget icon) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        height:size,
        child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(4)),
              child: icon,
            )));
  }
}
