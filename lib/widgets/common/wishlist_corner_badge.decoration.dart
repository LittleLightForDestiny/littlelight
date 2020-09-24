import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/widgets/common/corner_badge.decoration.dart';

class WishlistCornerBadgeDecoration extends CornerBadgeDecoration {
  final Set<WishlistTag> tags;

  const WishlistCornerBadgeDecoration({this.tags, double badgeSize})
      : super(badgeSize: badgeSize, colors: null);

  List<Color> get badgeColors {
    List<Color> colors = List();
    if (tags.contains(WishlistTag.PVE) || tags.contains(WishlistTag.GodPVE)) {
      colors.add(Colors.blue.shade800);
    }
    if (tags.contains(WishlistTag.Bungie)) {
      colors.add(Colors.black);
    }
    if (tags.contains(WishlistTag.PVP) || tags.contains(WishlistTag.GodPVP)) {
      colors.add(Colors.red.shade800);
    }
    if (colors.length > 0) {
      return colors;
    }
    if (tags.length == 0) {
      return [Colors.amber.shade500];
    }
    if (tags.contains(WishlistTag.Trash)) {
      return [Colors.lightGreen.shade500];
    }
    return null;
  }

  List<Color> get borderColors {
    List<Color> colors = List();
    if (tags.contains(WishlistTag.GodPVE)) {
      colors.add(Colors.amber.shade500);
    } else if (tags.contains(WishlistTag.PVE)) {
      colors.add(Colors.blue.shade800);
    }
    if (tags.contains(WishlistTag.Bungie)) {
      colors.add(Colors.black);
    }
    if (tags.contains(WishlistTag.GodPVP)) {
      colors.add(Colors.amber.shade500);
    } else if (tags.contains(WishlistTag.PVP)) {
      colors.add(Colors.red.shade800);
    }
    if (colors.length > 0) {
      return colors;
    }
    if (tags.length == 0) {
      return [Colors.amber.shade500];
    }
    if (tags.contains(WishlistTag.Trash)) {
      return [Colors.lightGreen.shade500];
    }
    return null;
  }

  @override
  BoxPainter createBoxPainter([onChanged]) =>
      WishlistBadgePainter(badgeColors, borderColors, badgeSize);
}

class WishlistBadgePainter extends CornerBadgePainter {
  List<Color> borderColors;

  WishlistBadgePainter(List<Color> colors, this.borderColors, double badgeSize)
      : super(colors, badgeSize);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    double size = badgeSize ?? configuration.size.width;
    canvas.save();
    canvas.translate(offset.dx + configuration.size.width - size, offset.dy);
    canvas.drawPath(buildBadgePath(size), getBadgePaint(size, borderColors));
    canvas.restore();
    canvas.translate(
        offset.dx + configuration.size.width - size * .8, offset.dy);
    canvas.drawPath(
        buildBadgePath(size * .8), getBadgePaint(size * .8, badgeColors));
    canvas.restore();
  }
}
