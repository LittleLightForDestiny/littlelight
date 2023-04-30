import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/triumphs/pages/subcategory/triumphs_subcategory.page_route.dart';
import 'package:little_light/modules/triumphs/blocs/base_triumphs.bloc.dart';

class TriumphsSubcategoryBloc extends TriumphsBloc {
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

  TriumphsSubcategoryBloc(BuildContext context, int this.rootNodeHash, {List<int>? parentNodeHashes})
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
      TriumphsSubcategoryPageRoute(presentationNodeHash, parentNodeHashes: [
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
}
