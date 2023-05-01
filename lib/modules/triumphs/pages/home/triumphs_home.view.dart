import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/triumphs/blocs/base_triumphs.bloc.dart';
import 'package:little_light/shared/views/base_presentation_node.view.dart';
import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item.widget.dart';
import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item_list.widget.dart';

class TriumphsHomeView extends BasePresentationNodeView {
  final TriumphsBloc bloc;
  final TriumphsBloc state;
  const TriumphsHomeView(this.bloc, this.state, {Key? key}) : super(key: key);

  @override
  List<DestinyPresentationNodeDefinition>? get tabNodes => bloc.tabNodes;

  @override
  List<int>? get breadcrumbHashes => null;

  @override
  bool get scrollableTabBar => true;

  @override
  String getTitle(BuildContext context) => "Triumphs".translate(context);

  Widget? buildAppBarLeading(BuildContext context) => IconButton(
        enableFeedback: false,
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      );

  Widget buildTabButton(BuildContext context, DestinyPresentationNodeDefinition node) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Text(node.displayProperties?.name ?? ""),
    );
  }

  Widget buildTab(BuildContext context, DestinyPresentationNodeDefinition node, EdgeInsets padding) {
    return PresentationNodeListWidget(
      node.hash,
      padding: padding,
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
