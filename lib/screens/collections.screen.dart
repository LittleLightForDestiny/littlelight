import 'package:flutter/material.dart';
import 'package:little_light/screens/collectible_search.screen.dart';
import 'package:little_light/screens/presentation_node.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/profile/destiny_settings.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/presentation_nodes/collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/nested_collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_tabs.widget.dart';

class CollectionsScreen extends PresentationNodeScreen {
  CollectionsScreen({int presentationNodeHash, depth = 0})
      : super(presentationNodeHash: presentationNodeHash, depth: depth);

  @override
  PresentationNodeScreenState createState() => new CollectionsScreenState();
}

class CollectionsScreenState
    extends PresentationNodeScreenState<CollectionsScreen> {
  Map<int, List<ItemWithOwner>> itemsByHash;
  @override
  void initState() {
    SelectedPagePersistence.saveLatestScreen(
        SelectedPagePersistence.collections);
    AuthService auth = AuthService();
    if (auth.isLogged) {
      this.loadItems();
    }
    super.initState();
  }

  loadItems() async {
    List<ItemWithOwner> allItems = [];
    ProfileService profile = ProfileService();
    Iterable<String> charIds =
        profile.getCharacters().map((char) => char.characterId);
    charIds.forEach((charId) {
      allItems.addAll(profile
          .getCharacterEquipment(charId)
          .map((item) => ItemWithOwner(item, charId)));
      allItems.addAll(profile
          .getCharacterInventory(charId)
          .map((item) => ItemWithOwner(item, charId)));
    });
    allItems.addAll(
        profile.getProfileInventory().map((item) => ItemWithOwner(item, null)));
    Map<int, List<ItemWithOwner>> itemsByHash = {};
    allItems.forEach((i) {
      int hash = i.item.itemHash;
      if (!itemsByHash.containsKey(hash)) {
        itemsByHash[hash] = [];
      }
      itemsByHash[hash].add(i);
    });
    this.itemsByHash = itemsByHash;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context), body: buildScaffoldBody(context));
  }

  Widget itemBuilder(CollectionListItem item, int depth) { 
    switch (item.type) {
      case CollectionListItemType.nestedCollectible:
        return NestedCollectibleItemWidget(
            hash: item.hash, itemsByHash: itemsByHash);

      case CollectionListItemType.collectible:
        return CollectibleItemWidget(
          hash: item.hash,
          itemsByHash: itemsByHash,
        );

      default:
        return super.itemBuilder(item, depth);
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    var settings = DestinySettingsService();
    return PresentationNodeTabsWidget(
      presentationNodeHashes: [
        settings.collectionsRootNode,
        settings.badgesRootNode
      ],
      depth: 0,
      itemBuilder: this.itemBuilder,
      tileBuilder: this.tileBuilder,
    );
  }

  buildAppBar(BuildContext context) {
    if (widget.depth == 0) {
      return AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollectibleSearchScreen(),
                  ),
                );
              },
            )
          ],
          title: TranslatedTextWidget("Collections"));
    }
    return AppBar(title: Text(definition?.displayProperties?.name ?? ""));
  }
}
