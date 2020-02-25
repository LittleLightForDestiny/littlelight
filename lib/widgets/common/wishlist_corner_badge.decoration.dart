import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/widgets/common/corner_badge.decoration.dart';

class WishlistCornerBadgeDecoration extends CornerBadgeDecoration {
  final Set<WishlistTag> tags;

  const WishlistCornerBadgeDecoration({this.tags, double badgeSize}):super(badgeSize:badgeSize, colors:null);

  List<Color> get badgeColors{
    List<Color> colors = List();
    print(tags);
    if(tags.contains(WishlistTag.PVE) || tags.contains(WishlistTag.GodPVE)){
      colors.add(Colors.blue.shade800);
    }
    if(tags.contains(WishlistTag.Bungie)){
      colors.add(Colors.black);
    }
    if(tags.contains(WishlistTag.PVP) || tags.contains(WishlistTag.GodPVP)){
      colors.add(Colors.red.shade800);
    }
    if(colors.length > 0){
      return colors;
    }
    if(tags.length == 0){
      return [Colors.amber.shade500];
    }
    if(tags.contains(WishlistTag.Trash)){
      return [Colors.lightGreen.shade500];
    }
    return null;
  }
}
