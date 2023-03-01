// @dart=2.9

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class WishlistNotesWidget extends StatelessWidget with WishlistsConsumer {
  final DestinyItemComponent item;
  final Map<String, List<DestinyItemPlugBase>> reusablePlugs;

  WishlistNotesWidget(this.item, {Key key, this.reusablePlugs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var notes = wishlistsService.getWishlistBuildNotes(itemHash: item.itemHash);
    if ((notes?.length ?? 0) == 0) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        HeaderWidget(
            child: Container(
          alignment: Alignment.centerLeft,
          child: TranslatedTextWidget(
            "Wishlist Notes",
            uppercase: true,
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        )),
        buildNotes(context, notes)
      ]),
    );
  }

  buildNotes(BuildContext context, Set<String> notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: notes
              ?.where((n) => (n?.length ?? 0) > 0)
              ?.map((n) =>
                  Container(padding: const EdgeInsets.all(4), child: Text(n)))
              ?.toList() ??
          [],
    );
  }
}
