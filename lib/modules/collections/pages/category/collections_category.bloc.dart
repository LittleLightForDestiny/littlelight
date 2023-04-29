import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/blocs/base_collections.bloc.dart';
import 'package:little_light/modules/collections/pages/subcategory/collections_subcategory.bloc.dart';
import 'package:little_light/modules/collections/pages/subcategory/collections_subcategory.page_route.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';

const _page = LittleLightPersistentPage.Collections;

class CollectionsCategoryBloc extends CollectionsBloc {
  final List<int>? _parentNodeHashes;
  final int rootNodeHash;

  @override
  List<DestinyPresentationNodeDefinition>? get tabNodes => _tabNodes;
  List<DestinyPresentationNodeDefinition>? _tabNodes;

  @override
  DestinyPresentationNodeDefinition? get rootNode => _rootNode;
  DestinyPresentationNodeDefinition? _rootNode;

  CollectionsCategoryBloc(BuildContext context, int this.rootNodeHash, {List<int>? parentNodeHashes})
      : this._parentNodeHashes = parentNodeHashes,
        super(context);

  @override
  Future<void> loadDefinitions() async {
    await loadNodeDefinitions([rootNodeHash]);
    final rootNode = nodeDefinitions[rootNodeHash];
    final childNodeHashes = rootNode?.children?.presentationNodes //
            ?.map((e) => e.presentationNodeHash)
            .whereType<int>() ??
        [];
    await loadNodeDefinitions(childNodeHashes);
    final tabNodes =
        childNodeHashes.map((e) => nodeDefinitions[e]).whereType<DestinyPresentationNodeDefinition>().toList();

    _rootNode = rootNode;
    _tabNodes = tabNodes;
  }

  @override
  List<int>? get parentNodeHashes => _parentNodeHashes;

  @override
  void update() {
    final hashes = tabNodes?.map((e) => e.hash);
    if (hashes == null) return;
    updatePresentationNodeChildren(hashes);
  }

  @override
  void openPresentationNode(int? presentationNodeHash, {List<int>? parentHashes}) {
    if (presentationNodeHash == null) return;
    final previousParentHashes = this.parentNodeHashes;
    Navigator.of(context).push(
      CollectionsSubcategoryPageRoute(presentationNodeHash, parentNodeHashes: [
        if (previousParentHashes != null) ...previousParentHashes,
        if (parentHashes != null) ...parentHashes,
      ]),
    );
  }
}
