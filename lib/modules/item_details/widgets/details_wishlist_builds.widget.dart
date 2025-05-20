import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/wishlist_helpers.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';
import 'package:little_light/shared/widgets/wishlists/wishlist_badge.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

const _perkIconSize = 32.0;

class DetailsWishlistBuildsWidget extends StatelessWidget {
  final MappedWishlistBuilds builds;
  final bool enableViewAllBuilds;
  final bool viewAllBuilds;
  final BoolCallback? onToggleViewAllBuilds;
  final Set<int>? allSelectedPlugHashes;
  final Set<int>? allEquippedPlugHashes;
  final Set<int>? allAvailablePlugHashes;

  const DetailsWishlistBuildsWidget(
    this.builds, {
    Key? key,
    this.enableViewAllBuilds = false,
    this.viewAllBuilds = false,
    this.onToggleViewAllBuilds,
    this.allSelectedPlugHashes,
    this.allEquippedPlugHashes,
    this.allAvailablePlugHashes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Wishlist Builds".translate(context).toUpperCase()),
          persistenceID: 'wishlist builds',
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
    if (!enableViewAllBuilds) return null;
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
              "View all builds".translate(context),
              style: context.textTheme.highlight,
            ),
            LLSwitch.callback(viewAllBuilds, (value) {
              onToggleViewAllBuilds?.call(value);
            }),
          ],
        ));
  }

  Widget? buildWishlist(
    BuildContext context,
    String wishlistName,
    Map<WishlistTag, List<ParsedWishlistBuild>> wishlists,
  ) {
    final columns = [
      buildWishlistSection(context, wishlists, [WishlistTag.GodPVE, WishlistTag.PVE]),
      buildWishlistSection(context, wishlists, [WishlistTag.GodPVP, WishlistTag.PVP]),
    ].whereType<Widget>();
    if (columns.isEmpty) return null;
    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.only(top: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          decoration: BoxDecoration(
            color: context.theme.secondarySurfaceLayers.layer1,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.all(4),
          margin: EdgeInsets.all(4),
          child: Text(
            wishlistName,
            style: context.textTheme.highlight,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columns.map((e) => Expanded(child: e)).toList(),
        ),
      ]),
    );
  }

  Widget? buildWishlistSection(
    BuildContext context,
    Map<WishlistTag, List<ParsedWishlistBuild>> wishlistBuilds,
    List<WishlistTag> tags,
  ) {
    final builds = tags.fold<List<ParsedWishlistBuild>>([], (list, element) => list + (wishlistBuilds[element] ?? []));
    if (builds.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: builds.map((e) => buildWishlistBuild(context, e)).toList(),
    );
  }

  Widget buildWishlistBuild(
    BuildContext context,
    ParsedWishlistBuild build,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer2,
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: build.tags.map((tag) => WishlistBadgeWidget(tag)).toList(),
            ),
            Container(margin: EdgeInsets.only(left: 8), child: buildWishlistBuildPerks(context, build)),
          ],
        ),
      ),
    );
  }

  Widget buildWishlistBuildPerks(
    BuildContext context,
    ParsedWishlistBuild wishlistBuild,
  ) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: wishlistBuild.plugs
            .map((perks) => Column(
                  children: perks.map((p) => buildWishlistPlug(context, p)).toList(),
                ))
            .toList());
  }

  Widget buildWishlistPlug(BuildContext context, int plugHash) {
    final def = context.definition<DestinyInventoryItemDefinition>(plugHash);
    final selected = allSelectedPlugHashes?.contains(plugHash) ?? false;
    final equipped = allEquippedPlugHashes?.contains(plugHash) ?? false;
    final available = !equipped && (allAvailablePlugHashes?.contains(plugHash) ?? false);
    final enhanced = def?.inventory?.tierType == TierType.Common;
    return Container(
        margin: EdgeInsets.only(right: 2, bottom: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_perkIconSize),
          border: selected ? Border.all(color: context.theme.onSurfaceLayers, width: .5) : null,
          color: (equipped || selected)
              ? context.theme.primaryLayers.layer1.withValues(alpha: selected ? 1 : .7)
              : available
                  ? context.theme.primaryLayers.layer1.withValues(alpha: .4)
                  : Colors.transparent,
        ),
        foregroundDecoration: enhanced
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(_perkIconSize),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    context.theme.achievementLayers.layer0.withValues(alpha: .5),
                    context.theme.achievementLayers.layer0.withValues(alpha: 0),
                  ],
                ))
            : null,
        width: _perkIconSize,
        height: _perkIconSize,
        child: ManifestImageWidget<DestinyInventoryItemDefinition>(plugHash));
  }
}
