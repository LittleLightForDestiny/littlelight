// import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
// import 'package:flutter/material.dart';
// import 'package:little_light/services/manifest/manifest.consumer.dart';
// import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
// import 'package:little_light/widgets/common/loading_anim.widget.dart';
// import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
// import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';
// // ignore: import_of_legacy_library_into_null_safe
// import 'package:little_light/widgets/presentation_nodes/nested_collectible_item.widget.dart';
// // ignore: import_of_legacy_library_into_null_safe
// import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item.widget.dart';

// typedef PresentationNodeTap = void Function(int presentationNodeHash);

// class CategorySetsListWidget extends StatefulWidget {
//   final DestinyPresentationNodeDefinition node;
//   final PresentationNodeTap? onItemTap;
//   const CategorySetsListWidget({Key? key, required this.node, this.onItemTap}) : super(key: key);

//   @override
//   _CategorySetsListWidgetState createState() => _CategorySetsListWidgetState();
// }

// class _CategorySetsListWidgetState extends State<CategorySetsListWidget> with ManifestConsumer {
//   List<DestinyPresentationNodeDefinition>? nodeDefinitions;

//   @override
//   void initState() {
//     super.initState();
//     loadDefinitions();
//   }

//   void loadDefinitions() async {
//     final nodeHashes = widget.node.children?.presentationNodes?.map((e) => e.presentationNodeHash).toList();
//     if (nodeHashes == null) return;
//     final nodeDefs = await manifest.getDefinitions<DestinyPresentationNodeDefinition>(nodeHashes);
//     final nodes = nodeHashes.map((e) => nodeDefs[e]).whereType<DestinyPresentationNodeDefinition>().toList();
//     setState(() {
//       nodeDefinitions = nodes;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final nodeDefinitions = this.nodeDefinitions;
//     if (nodeDefinitions == null) return LoadingAnimWidget();
//     List<SliverSection> sections = <SliverSection>[];
//     for (var node in nodeDefinitions) {
//       final collectibles = node.children?.collectibles;
//       if (collectibles == null) continue;
//       sections += [
//         SliverSection(
//           itemCount: 1,
//           itemHeight: 64,
//           itemBuilder: (context, index) => buildPresentationNode(context, node),
//         ),
//         SliverSection(
//           itemCount: collectibles.length,
//           itemAspectRatio: 1,
//           itemsPerRow: MediaQueryHelper(context).responsiveValue(5, tablet: 10, laptop: 15, desktop: 20),
//           itemBuilder: (context, index) => buildNestedCollectible(context, node, index),
//         )
//       ];
//     }
//     return MultiSectionScrollView(
//       sections,
//       padding: const EdgeInsets.all(4) + MediaQuery.of(context).viewPadding,
//       crossAxisSpacing: 2,
//       mainAxisSpacing: 2,
//     );
//   }

//   Widget buildPresentationNode(BuildContext context, DestinyPresentationNodeDefinition node) {
//     return PresentationNodeItemWidget(
//       presentationNodeHash: node.hash,
//       onTap: () {},
//     );
//   }

//   Widget buildNestedCollectible(BuildContext context, DestinyPresentationNodeDefinition node, int index) {
//     final childNode = node.children?.collectibles?[index];
//     final collectibleHash = childNode?.collectibleHash;
//     if (collectibleHash == null) return Container();
//     return NestedCollectibleItemWidget(hash: collectibleHash);
//   }
// }
