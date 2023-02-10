import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class CategoryBreadcrumbWidget extends StatefulWidget implements PreferredSizeWidget {
  final List<int> parentCategoryHashes;

  const CategoryBreadcrumbWidget({
    Key? key,
    required this.parentCategoryHashes,
  }) : super(key: key);

  @override
  _CategoryBreadcrumbWidgetState createState() => _CategoryBreadcrumbWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(32);
}

class _CategoryBreadcrumbWidgetState extends State<CategoryBreadcrumbWidget> with ManifestConsumer {
  List<DestinyPresentationNodeDefinition>? nodeDefinitions;

  TabController? get tabController => DefaultTabController.of(context);

  @override
  void initState() {
    super.initState();
    initTabListener();
    loadDefinitions();
  }

  void initTabListener() async {
    await Future.delayed(Duration.zero);
    tabController?.addListener(tabListener);
  }

  void loadDefinitions() async {
    final defs = await manifest.getDefinitions<DestinyPresentationNodeDefinition>(widget.parentCategoryHashes);
    setState(() {
      nodeDefinitions =
          widget.parentCategoryHashes.map((hash) => defs[hash]).whereType<DestinyPresentationNodeDefinition>().toList();
    });
  }

  @override
  void deactivate() {
    tabController?.removeListener(tabListener);
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void tabListener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final nodeDefinitions = this.nodeDefinitions;
    if (nodeDefinitions == null) return Container();
    final nodes = nodeDefinitions.last.children?.presentationNodes;
    if (nodes == null) return Container();
    final last = nodes.isNotEmpty ? nodes[tabController?.index ?? 0].presentationNodeHash : null;
    return Container(
        constraints: const BoxConstraints.expand(height: 32),
        child: Material(
            key: Key("breadcrumb_$last"),
            color: LittleLightTheme.of(context).surfaceLayers.layer1,
            elevation: 0,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                        children: nodeDefinitions
                            .map<Widget>((def) => Text("${def.displayProperties?.name} ${def != nodeDefinitions.last || last != null ? '// ' : ''}"))
                            .followedBy([
                      if (last != null) ManifestText<DestinyPresentationNodeDefinition>(last)
                    ]).toList())))));
  }
}
