import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/blocs/base_collections.bloc.dart';
import 'package:little_light/modules/collections/pages/subcategory/collections_subcategory.page_route.dart';

class CollectionsSubcategoryBloc extends CollectionsBloc {
  @override
  List<int>? get parentNodeHashes => _parentNodeHashes;
  final List<int>? _parentNodeHashes;

  @override
  List<DestinyPresentationNodeDefinition>? get tabNodes =>
      [_rootNode].whereType<DestinyPresentationNodeDefinition>().toList();

  @override
  DestinyPresentationNodeDefinition? get rootNode => _rootNode;
  DestinyPresentationNodeDefinition? _rootNode;
  final int rootNodeHash;

  CollectionsSubcategoryBloc(BuildContext context, int this.rootNodeHash, {List<int>? parentNodeHashes})
      : this._parentNodeHashes = parentNodeHashes,
        super(context);

  @override
  Future<void> loadDefinitions() async {
    await loadNodeDefinitions([rootNodeHash]);
    final rootNode = nodeDefinitions[rootNodeHash];
    _rootNode = rootNode;
  }

  @override
  void openPresentationNode(int? presentationNodeHash, {List<int>? parentHashes}) {
    if (presentationNodeHash == null) return;
    Navigator.of(context).push(
      CollectionsSubcategoryPageRoute(presentationNodeHash, parentNodeHashes: [
        if (parentHashes != null) ...parentHashes,
        presentationNodeHash,
      ]),
    );
  }

  @override
  Future<void> update() async {
    final hashes = tabNodes?.map((e) => e.hash);
    if (hashes == null) return;
    await updatePresentationNodeChildren(hashes);
  }

  @override
  void openSearch() {}
}
