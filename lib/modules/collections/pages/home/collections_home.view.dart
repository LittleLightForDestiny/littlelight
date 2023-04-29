import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/collections/blocs/base_collections.bloc.dart';
import 'package:little_light/shared/views/base_presentation_node.view.dart';
import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item.widget.dart';
import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item_list.widget.dart';

class CollectionsHomeView extends BasePresentationNodeView {
  final CollectionsBloc bloc;
  final CollectionsBloc state;
  const CollectionsHomeView(this.bloc, this.state, {Key? key}) : super(key: key);

  @override
  List<DestinyPresentationNodeDefinition>? get tabNodes => bloc.tabNodes;

  @override
  List<int>? get breadcrumbHashes => null;

  @override
  String getTitle(BuildContext context) => "Collections".translate(context);

  Widget? buildAppBarLeading(BuildContext context) => IconButton(
        enableFeedback: false,
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      );

  Widget buildTabButton(BuildContext context, DestinyPresentationNodeDefinition node) {
    return Container(
      alignment: Alignment.center,
      child: Text(node.displayProperties?.name ?? ""),
    );
  }

  Widget buildTab(BuildContext context, DestinyPresentationNodeDefinition node, EdgeInsets padding) {
    return PresentationNodeListWidget(
      node.hash,
      presentationNodeBuilder: (context, entry) => PresentationNodeItemWidget(
        entry.presentationNodeHash,
        progress: state.getProgress(entry.presentationNodeHash),
        characters: state.characters,
        onTap: () => bloc.openPresentationNode(
          entry.presentationNodeHash,
          parentHashes: [node.hash].whereType<int>().toList(),
        ),
      ),
    );
  }
}
