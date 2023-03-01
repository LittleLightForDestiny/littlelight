// @dart=2.9

import 'dart:math';

import 'package:bungie_api/models/destiny_item_plug_base.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_details/section_header.widget.dart';
import 'package:little_light/widgets/wishlist_builds/wishlist_build_perks.widget.dart';

const _sectionId = "wishlist_builds";

extension WishlistBuildSortingPriority on ParsedWishlistBuild {
  int get inputPriority {
    if (tags.containsAll([WishlistTag.Mouse, WishlistTag.Controller])) {
      return 0;
    }
    if (tags.contains(WishlistTag.Mouse)) {
      return 1;
    }
    if (tags.contains(WishlistTag.Controller)) {
      return 2;
    }
    return 0;
  }

  int get activityTypePriority {
    if (tags.containsAll([WishlistTag.GodPVE, WishlistTag.GodPVP])) {
      return 0;
    }
    if (tags.containsAll([WishlistTag.PVE, WishlistTag.PVP])) {
      return 1;
    }
    if (tags.contains(WishlistTag.GodPVE)) {
      return 2;
    }
    if (tags.contains(WishlistTag.PVE)) {
      return 3;
    }
    if (tags.contains(WishlistTag.GodPVP)) {
      return 4;
    }
    if (tags.contains(WishlistTag.PVP)) {
      return 5;
    }
    return 6;
  }
}

class WishlistBuildsWidget extends StatefulWidget {
  final int itemHash;
  final Map<String, List<DestinyItemPlugBase>> reusablePlugs;
  const WishlistBuildsWidget(
    this.itemHash, {
    Key key,
    this.reusablePlugs,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => WishlistBuildsWidgetState();
}

class WishlistBuildsWidgetState extends State<WishlistBuildsWidget>
    with VisibleSectionMixin, WishlistsConsumer {
  @override
  void initState() {
    super.initState();
  }

  @override
  String get sectionId => _sectionId;

  @override
  Widget build(BuildContext context) {
    final builds = wishlistsService.getWishlistBuilds(
        itemHash: widget.itemHash, reusablePlugs: widget.reusablePlugs);
    if ((builds?.length ?? 0) == 0) return Container();
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        getHeader(
          TranslatedTextWidget(
            "Wishlist Builds",
            uppercase: true,
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        visible ? buildWishlists(context, builds) : Container()
      ]),
    );
  }

  Widget buildWishlists(
      BuildContext context, List<ParsedWishlistBuild> builds) {
    Set<String> wishlists = builds.map((b) => b.originalWishlist ?? "").toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: wishlists
              ?.map((name) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildWishlistTitle(context, name),
                        buildWishlistBuilds(context, name, builds)
                      ]))
              ?.toList() ??
          [],
    );
  }

  Widget buildWishlistTitle(BuildContext context, String title) {
    if ((title ?? "").isEmpty) return Container();
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title),
    );
  }

  Widget buildWishlistBuilds(BuildContext context, String originalWishlistName,
      List<ParsedWishlistBuild> builds) {
    final wishlistBuilds = builds
        .where((element) => element.originalWishlist == originalWishlistName)
        .toList();
    wishlistBuilds.sort((a, b) {
      var inputPriority = a.inputPriority.compareTo(b.inputPriority);
      if (inputPriority != 0) return inputPriority;
      return a.activityTypePriority.compareTo(b.activityTypePriority);
    });
    var crossAxisCount = MediaQueryHelper(context).tabletOrBigger ? 4 : 2;
    List<List<ParsedWishlistBuild>> rows = [];
    for (var i = 0; i < wishlistBuilds.length; i += crossAxisCount) {
      final start = i;
      final end = min(i + crossAxisCount, wishlistBuilds.length);
      rows.add(wishlistBuilds.sublist(start, end));
    }
    return Column(
      children: rows
          .map((r) => IntrinsicHeight(
                  child: Row(
                children: r
                    .map((b) => Expanded(
                          child: WishlistBuildPerksWidget(
                            wishlistBuild: b,
                          ),
                        ))
                    .fold(
                        <Widget>[],
                        (previousValue, element) => previousValue
                            .followedBy([Container(width: 8), element]))
                    .skip(1)
                    .toList(),
              )))
          .fold(
              <Widget>[],
              (previousValue, element) =>
                  previousValue.followedBy([Container(height: 8), element]))
          .skip(1)
          .toList(),
    );
  }
}
