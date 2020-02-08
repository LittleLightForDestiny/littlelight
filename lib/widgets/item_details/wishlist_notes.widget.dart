import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class WishlistNotesWidget extends StatelessWidget {
  final DestinyItemComponent item;

  WishlistNotesWidget(this.item, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var notes = WishlistsService().getWishlistBuildNotes(item);
    if (notes == null) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(children: [
        HeaderWidget(
            child: Container(
          alignment: Alignment.centerLeft,
          child: TranslatedTextWidget(
            "Wishlist Notes",
            uppercase: true,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )),
        buildNotes(context, notes)
      ]),
    );
  }

  buildNotes(BuildContext context, Set<String> notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
          notes?.where((n)=>(n?.length ?? 0) > 0)?.map((n) => Container(
            padding: EdgeInsets.all(4),
            child: Text("$n")))?.toList() ?? [],
    );
  }
}
