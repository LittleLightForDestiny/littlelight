import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/triumphs/blocs/base_triumphs.bloc.dart';
import 'package:little_light/modules/triumphs/views/triumphs_base.view.dart';
import 'package:little_light/modules/triumphs/widgets/record_item.widget.dart';
import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item.widget.dart';
import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item_list.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class TriumphsCategoryView extends BaseTriumphsView {
  final TriumphsBloc bloc;
  final TriumphsBloc state;
  const TriumphsCategoryView(this.bloc, this.state, {Key? key}) : super(key: key);

  @override
  List<int>? get breadcrumbHashes => state.parentNodeHashes;

  @override
  List<DestinyPresentationNodeDefinition>? get tabNodes => bloc.tabNodes;

  @override
  String getTitle(BuildContext context) => state.rootNode?.displayProperties?.name ?? "";

  Widget? buildAppBarLeading(BuildContext context) => null;

  Widget buildTabButton(BuildContext context, DestinyPresentationNodeDefinition node) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(4),
      child: ManifestImageWidget<DestinyPresentationNodeDefinition>(node.hash),
    );
  }

  Widget buildTab(BuildContext context, DestinyPresentationNodeDefinition node, EdgeInsets padding) {
    return PresentationNodeListWidget(
      node.hash,
      padding: padding,
      presentationNodeBuilder: (context, entry) {
        return PresentationNodeItemWidget(
          entry.presentationNodeHash,
          progress: state.getProgress(entry.presentationNodeHash),
          characters: state.characters,
          onTap: () => bloc.openPresentationNode(
            entry.presentationNodeHash,
            parentHashes: [node.hash].whereType<int>().toList(),
          ),
        );
      },
      recordBuilder: (context, entry) => RecordItemWidget(
        entry.recordHash,
        progress: state.getRecordProgress(entry.recordHash),
        onTap: () => bloc.onRecordTap(entry.recordHash),
      ),
    );
  }
}
