import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/triumphs/pages/home/triumphs_home.bloc.dart';
import 'package:little_light/modules/triumphs/views/triumphs_base.view.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/fixed_height_scrollable_section.dart';
import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item.widget.dart';

const _itemHeight = 96.0;

class TriumphsHomeView extends BaseTriumphsView {
  final TriumphsHomeBloc bloc;
  final TriumphsHomeBloc state;
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
    final itemsPerRow = MediaQueryHelper(context).responsiveValue(1, tablet: 2, desktop: 3);
    final def = context.definition<DestinyPresentationNodeDefinition>(node.hash);

    final additionalPresentationNodes = state.getAdditionalNodes(node.hash) ?? [];
    final presentationNodes = [
      ...(def?.children?.presentationNodes ?? []),
      for (final additional in additionalPresentationNodes) ...(additional.children?.presentationNodes ?? [])
    ].whereType<DestinyPresentationNodeChildEntry>().toList();

    return MultiSectionScrollView(
      [
        FixedHeightScrollSection(_itemHeight,
            itemsPerRow: itemsPerRow,
            itemCount: presentationNodes.length,
            itemBuilder: (context, index) => PresentationNodeItemWidget(presentationNodes[index].presentationNodeHash,
                progress: state.getProgress(presentationNodes[index].presentationNodeHash),
                characters: state.characters,
                onTap: () => bloc.openPresentationNode(
                      presentationNodes[index].presentationNodeHash,
                      parentHashes: [node.hash].whereType<int>().toList(),
                    ))),
      ],
      padding: padding,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    );
  }
}
