import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class WishlistBuildPerksWidget extends StatefulWidget {
  final WishlistBuild build;
  final double perkIconSize;

  const WishlistBuildPerksWidget({Key key, this.build, this.perkIconSize = 32})
      : super(key: key);

  @override
  _WishlistBuildPerksWidgetState createState() =>
      _WishlistBuildPerksWidgetState();
}

class _WishlistBuildPerksWidgetState extends State<WishlistBuildPerksWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [buildTags(context), buildPlugs(context)],
    );
  }

  Widget buildTags(BuildContext contxt) {
    return Row(
        children: widget.build.tags.map((t) => Text(t.toString())).toList());
  }

  Widget buildPlugs(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.build.perks
                .map((perks) => Column(
                      children: perks
                          .map((p) => Container(
                              width: widget.perkIconSize,
                              height: widget.perkIconSize,
                              child: ManifestImageWidget<
                                  DestinyInventoryItemDefinition>(p)))
                          .toList(),
                    ))
                .toList()));
  }
}
