import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/loadouts/pages/select_background/select_loadout_background.bloc.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';
import 'package:provider/provider.dart';

class SelectLoadoutBackgroundView extends StatelessWidget {
  const SelectLoadoutBackgroundView() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(title: Text("Select Loadout Background".translate(context)));
  }

  Widget buildBody(BuildContext context) {
    final state = context.watch<SelectLoadoutBackgroundBloc>();
    final nodesDefinitions = state.nodesDefinitions;
    if (nodesDefinitions == null) return LoadingAnimWidget();
    return MultiSectionScrollView(
      nodesDefinitions
          .map((def) => [
                buildCategoryHeaderSection(def),
                buildCategoryItemsSection(context, def.hash!),
              ])
          .flattened
          .whereType<SliverSection>()
          .toList(),
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      padding: MediaQuery.of(context).viewPadding.copyWith(top: 0) + const EdgeInsets.all(4),
    );
  }

  SliverSection buildCategoryHeaderSection(DestinyPresentationNodeDefinition nodeDef) => SliverSection(
        itemBuilder: (context, _) => buildCategoryItem(context, nodeDef),
        itemHeight: 60,
        itemCount: 1,
      );

  SliverSection? buildCategoryItemsSection(BuildContext context, int hash) {
    final state = context.watch<SelectLoadoutBackgroundBloc>();
    if (!state.isCategoryOpen(hash)) {
      return null;
    }
    final items = state.getCategoryItems(hash);
    if (items != null && items.isNotEmpty) {
      return SliverSection(
          itemBuilder: (context, index) => buildEmblemItem(context, items[index]),
          itemHeight: 56,
          itemCount: items.length);
    }
    return SliverSection(itemBuilder: (context, index) => LoadingAnimWidget(), itemAspectRatio: 1, itemCount: 1);
  }

  Widget buildCategoryItem(BuildContext context, DestinyPresentationNodeDefinition def) {
    final color = LittleLightTheme.of(context).onSurfaceLayers.layer3;
    return Material(
      child: InkWell(
        child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: const Alignment(0, 0),
                end: const Alignment(1, 2),
                colors: [color.withOpacity(.05), color.withOpacity(.1), color.withOpacity(.03), color.withOpacity(.1)]),
            border: Border.all(color: color, width: 1),
          ),
          padding: const EdgeInsets.all(16),
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
        onTap: () => context.read<SelectLoadoutBackgroundBloc>().toggleCategory(def.hash!),
      ),
    );
  }

  Widget buildEmblemItem(BuildContext context, DestinyInventoryItemDefinition def) {
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
}
