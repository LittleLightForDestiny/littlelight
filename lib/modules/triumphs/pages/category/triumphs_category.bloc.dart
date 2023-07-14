import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/triumphs/blocs/base_triumphs.bloc.dart';
import 'package:little_light/modules/triumphs/pages/subcategory/triumphs_subcategory.page_route.dart';

class TriumphsCategoryBloc extends TriumphsBloc {
  final List<int>? _parentNodeHashes;
  final int rootNodeHash;

  @override
  List<DestinyPresentationNodeDefinition>? get tabNodes => _tabNodes;
  List<DestinyPresentationNodeDefinition>? _tabNodes;

  @override
  DestinyPresentationNodeDefinition? get rootNode => _rootNode;
  DestinyPresentationNodeDefinition? _rootNode;

  TriumphsCategoryBloc(BuildContext context, int this.rootNodeHash, {List<int>? parentNodeHashes})
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
    _tabNodes = tabNodes.isNotEmpty ? tabNodes : [rootNode].whereType<DestinyPresentationNodeDefinition>().toList();
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
      TriumphsSubcategoryPageRoute(presentationNodeHash, parentNodeHashes: [
        if (previousParentHashes != null) ...previousParentHashes,
        if (parentHashes != null) ...parentHashes,
      ]),
    );
  }
}
