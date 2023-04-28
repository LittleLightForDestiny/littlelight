import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/shared/utils/helpers/wishlist_helpers.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';
import 'package:little_light/shared/widgets/wishlists/wishlist_badge.widget.dart';

class DetailsWishlistNotesWidget extends StatelessWidget {
  final MappedWishlistNotes builds;
  final bool enableViewAllNotes;
  final bool viewAllNotes;
  final BoolCallback? onToggleViewAllNotes;

  const DetailsWishlistNotesWidget(
    this.builds, {
    Key? key,
    this.enableViewAllNotes = false,
    this.viewAllNotes = false,
    this.onToggleViewAllNotes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Wishlist Notes".translate(context).toUpperCase()),
          persistenceID: 'wishlist notes',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          buildAllWishlistsToggle(context),
          ...builds.entries.map((b) => buildWishlist(context, b.key, b.value)).whereType<Widget>().toList()
        ].whereType<Widget>().toList(),
      ),
    );
  }

  Widget? buildAllWishlistsToggle(BuildContext context) {
    if (!enableViewAllNotes) return null;
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: context.theme.surfaceLayers.layer3,
        ),
        padding: EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "View all notes".translate(context),
              style: context.textTheme.highlight,
            ),
            LLSwitch.callback(viewAllNotes, (value) {
              onToggleViewAllNotes?.call(value);
            }),
          ],
        ));
  }

  Widget? buildWishlist(
    BuildContext context,
    String wishlistName,
    Map<String, Set<WishlistTag>> notes,
  ) {
    final columns = notes.entries.map((n) => buildNotes(context, wishlistName, n.value, n.key)).whereType<Widget>();
    if (columns.isEmpty) return null;
    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.only(top: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ...columns,
      ]),
    );
  }

  Widget buildNotes(BuildContext context, String wishlistName, Set<WishlistTag> tags, String notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.theme.secondarySurfaceLayers.layer1,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.all(4),
          margin: EdgeInsets.all(4),
          child: Row(children: [
            ...tags.map(
              (e) => Container(
                child: WishlistBadgeWidget(e),
                margin: EdgeInsets.only(right: 4),
              ),
            ),
            Expanded(
                child: Text(
              wishlistName,
              style: context.textTheme.highlight,
            )),
          ]),
        ),
        Container(
            padding: EdgeInsets.all(8),
            child: Text(
              notes,
              style: context.textTheme.body,
            )),
      ],
    );
  }
}
