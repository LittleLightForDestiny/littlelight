import 'package:flutter/material.dart';
import 'package:little_light/screens/base/presentation_node_base.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/presentation_nodes/collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/nested_collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';

class CollectionsScreen extends PresentationNodeBaseScreen {
  CollectionsScreen(
      {int presentationNodeHash, depth = 0})
      : super(presentationNodeHash: presentationNodeHash, depth: depth);

  @override
  PresentationNodeBaseScreenState createState() => new CollectionsScreenState();
}

class CollectionsScreenState extends PresentationNodeBaseScreenState {
  Map<int, List<ItemWithOwner>> itemsByHash;
  @override
  void initState() {
    SelectedPagePersistence.saveLatestScreen(
        SelectedPagePersistence.collections);
    AuthService auth = AuthService();
    if (auth.isLogged) {
      ProfileService()
          .fetchProfileData(components: ProfileComponentGroups.collections);
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
        appBar: buildAppBar(context),
        body: buildScaffoldBody(context));
  }

  Widget buildScaffoldBody(BuildContext context){
    if(definition == null) return Container();
    return Stack(children: [
          Column(children: [
            Expanded(
                child: buildBody(context, hash:widget.presentationNodeHash,
                    depth:widget.depth < 2 ? widget.depth : widget.depth + 1)),
            SelectedItemsWidget(),
          ]),
          InventoryNotificationWidget(
            key: Key('inventory_notification_widget'),
            barHeight: 0,
          ),
        ]);
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
          title: TranslatedTextWidget("Collections"));
    }
    return AppBar(title: Text(definition.displayProperties.name));
  }

  @override
  void onPresentationNodePressed(int hash, int depth) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionsScreen(
              presentationNodeHash: hash,
              depth: depth + 1,
            ),
      ),
    );
  }

  @override
  Widget itemBuilder(CollectionListItem item) {
    switch (item.type) {
      case CollectionListItemType.presentationNode:
        return PresentationNodeItemWidget(
          hash: item.hash,
          depth: widget.depth,
          onPressed: onPresentationNodePressed,
        );

      case CollectionListItemType.nestedCollectible:
        return NestedCollectibleItemWidget(
          hash: item.hash,
          itemsByHash: itemsByHash,
        );

      case CollectionListItemType.collectible:
        return CollectibleItemWidget(
          hash: item.hash,
          itemsByHash: itemsByHash,
        );

      default:
        return Container(color: Colors.red);
    }
  }
}
