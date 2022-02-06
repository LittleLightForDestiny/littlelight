//@dart=2.12

import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';

const _shaderRootHash = 2381001021;

class SelectLoadoutBackgroundScreen extends StatefulWidget {
  SelectLoadoutBackgroundScreen() : super();

  @override
  SelectLoadoutBackgroundScreenState createState() => new SelectLoadoutBackgroundScreenState();
}

class SelectLoadoutBackgroundScreenState extends State<SelectLoadoutBackgroundScreen>
    with DestinySettingsConsumer, ManifestConsumer {
  DestinyPresentationNodeDefinition? categoryDefinition;
  List<DestinyPresentationNodeDefinition>? nodesDefinitions;
  Set<int> openedCategories = Set<int>();
  Map<int, List<DestinyInventoryItemDefinition>> categoryItems = Map<int, List<DestinyInventoryItemDefinition>>();

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  asyncInit() async {
    await Future.delayed(Duration.zero);
    final route = ModalRoute.of(context);
    await Future.delayed(route?.transitionDuration ?? Duration.zero);
    loadNodes();
  }

  Future<void> loadNodes() async {
    await Future.delayed(Duration.zero);
    final route = ModalRoute.of(context);
    await Future.delayed(route?.transitionDuration ?? Duration.zero);
    final categoryDefinition = await manifest.getDefinition<DestinyPresentationNodeDefinition>(_shaderRootHash);
    final nodeHashes = categoryDefinition?.children?.presentationNodes?.map((e) => e.presentationNodeHash);
    if (nodeHashes == null) return;
    final nodesDefinitions = await manifest.getDefinitions<DestinyPresentationNodeDefinition>(nodeHashes);
    setState(() {
      this.categoryDefinition = categoryDefinition;
      this.nodesDefinitions = nodesDefinitions.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(title: TranslatedTextWidget("Select Loadout Background"));
  }

  Widget buildBody(BuildContext context) {
    final nodesDefinitions = this.nodesDefinitions;
    if (nodesDefinitions == null) return LoadingAnimWidget();
    List<SliverSection> sections = [];
    for (final def in nodesDefinitions) {
      sections += [
        SliverSection(
            itemBuilder: (context, index) {
              return buildCategoryItem(context, def);
            },
            itemHeight: 60,
            itemCount: 1)
      ];
      final isOpened = openedCategories.contains(def.hash);
      final items = categoryItems[def.hash];
      if (isOpened) {
        if (items != null) {
          sections += [
            SliverSection(
                itemBuilder: (context, index) {
                  return buildEmblem(context, items[index]);
                },
                itemHeight: 56,
                itemCount: items.length)
          ];
        } else {
          sections += [
            SliverSection(itemBuilder: (context, index) => LoadingAnimWidget(), itemCount: 1),
          ];
        }
      }
    }
    return MultiSectionScrollView(
      sections,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      padding: MediaQuery.of(context).viewPadding.copyWith(top: 0) + EdgeInsets.all(4),
    );
  }

  Widget buildCategoryItem(BuildContext context, DestinyPresentationNodeDefinition def) {
    final color = LittleLightTheme.of(context).onSurfaceLayers.layer3;
    return Material(
      child: InkWell(
        child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment(0, 0),
                end: Alignment(1, 2),
                colors: [color.withOpacity(.05), color.withOpacity(.1), color.withOpacity(.03), color.withOpacity(.1)]),
            border: Border.all(color: color, width: 1),
          ),
          padding: EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
                child: Text(
              "${def.displayProperties?.name}",
              style: LittleLightTheme.of(context).textTheme.subtitle,
            )),
            ManifestText<DestinyObjectiveDefinition>(
              def.objectiveHash!,
              textExtractor: (def) => "${def.completionValue}",
              style: LittleLightTheme.of(context).textTheme.subtitle,
            )
          ]),
        ),
        onTap: () {
          toggleCategory(def.hash!);
        },
      ),
    );
  }

  Widget buildEmblem(BuildContext context, DestinyInventoryItemDefinition def) {
    final color = LittleLightTheme.of(context).onSurfaceLayers.layer3;
    final url = def.secondarySpecial;
    final hash = def.hash;
    if (url == null || hash == null) return Container();
    return Stack(
      key: Key('emblem_$hash'),
      children: [
        Positioned.fill(
            child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1),
          ),
          child: QueuedNetworkImage.fromBungie(
            url,
            fit: BoxFit.cover,
          ),
        )),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop(hash);
            },
          ),
        )
      ],
    );
  }

  void toggleCategory(int hash) async {
    if (openedCategories.contains(hash)) {
      openedCategories.remove(hash);
    } else {
      openedCategories.add(hash);
    }
    setState(() {});
    if (!categoryItems.containsKey(hash) && openedCategories.contains(hash)) {
      final category = nodesDefinitions?.firstWhereOrNull((def) => def.hash == hash);
      final collectibleHashes = category?.children?.collectibles?.map((c) => c.collectibleHash);
      if (collectibleHashes == null) return;
      final collectibles = await manifest.getDefinitions<DestinyCollectibleDefinition>(collectibleHashes);
      final itemHashes = collectibles.values.map((e) => e.itemHash).whereType<int>();
      final items = await manifest.getDefinitions<DestinyInventoryItemDefinition>(itemHashes);
      final alreadyAddedImages = <String>[];
      final categoryItems = collectibleHashes
          .map((h) => collectibles[h]?.itemHash)
          .whereType<int>()
          .map((itemHash) => items[itemHash])
          .whereType<DestinyInventoryItemDefinition>()
          .where((item) {
        final secondarySpecial = item.secondarySpecial;
        if (secondarySpecial == null) return false;
        final alreadyAdded = alreadyAddedImages.contains(secondarySpecial);
        alreadyAddedImages.add(secondarySpecial);
        return !alreadyAdded;
      }).toList();
      setState(() {
        this.categoryItems[hash] = categoryItems;
      });
    }
  }
}
