import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/views/base_presentation_node.view.dart';
import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';

import 'collections_home.bloc.dart';

class CollectionsHomeView extends BasePresentationNodeView {
  final CollectionsHomeBloc bloc;
  final CollectionsHomeBloc state;
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
    return MultiSectionScrollView(
      [
        SliverSection(
          itemsPerRow: MediaQueryHelper(context).responsiveValue(1, tablet: 2, desktop: 3),
          itemCount: node.children?.presentationNodes?.length ?? 0,
          itemHeight: 80,
          itemBuilder: (context, index) => buildItem(context, node.children?.presentationNodes?[index]),
        )
      ],
      padding: padding,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    );
  }

  Widget buildItem(BuildContext context, DestinyPresentationNodeChildEntry? presentationNode) {
    final presentationNodeHash = presentationNode?.presentationNodeHash;
    if (presentationNodeHash == null) return Container();
    return PresentationNodeItemWidget(
      presentationNodeHash,
      progress: state.getProgress(presentationNodeHash),
      characters: state.characters,
      onTap: () => bloc.openPresentationNode(presentationNodeHash),
    );
  }
}
