import 'dart:math';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/loadouts/pages/home/little_light_loadouts.bloc.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_list_item.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/intrinsic_height_scrollable_section.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class LittleLightLoadoutsView extends StatelessWidget {
  final LittleLightLoadoutsBloc bloc;
  final LittleLightLoadoutsBloc state;
  const LittleLightLoadoutsView({
    required this.bloc,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.reordering) {
      return buildReorderingBody(context);
    }

    return buildLoadoutsList(context);
  }

  Widget buildReorderingBody(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;

    return ReorderableList(
        itemCount: state.loadouts?.length ?? 0,
        itemBuilder: (context, index) {
          return buildSortItem(context, index);
        },
        itemExtent: 56,
        padding: const EdgeInsets.all(8).copyWith(left: max(screenPadding.left, 8), right: max(screenPadding.right, 8)),
        onReorder: (oldIndex, newIndex) => bloc.reorderLoadouts(oldIndex, newIndex));
  }

  Widget buildHandle(BuildContext context, int index) {
    return ReorderableDragStartListener(
        index: index,
        child: AspectRatio(aspectRatio: 1, child: Container(color: Colors.transparent, child: const Icon(Icons.menu))));
  }

  Widget buildSortItem(BuildContext context, int index) {
    final loadout = state.loadouts?[index];
    if (loadout == null) return Container();
    return Container(
        key: Key("loadout-${loadout.loadoutId}"),
        padding: const EdgeInsets.symmetric(vertical: 4),
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            loadout.emblemHash != null
                ? Positioned.fill(
                    child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                    loadout.emblemHash,
                    urlExtractor: (def) => def.secondarySpecial,
                    fit: BoxFit.cover,
                  ))
                : Container(),
            Row(
              children: <Widget>[
                buildHandle(context, index),
                Expanded(
                  child: Text(
                    loadout.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget buildLoadoutsList(BuildContext context) {
    final loadouts = state.loadouts;
    if (state.isLoading || loadouts == null) {
      return LoadingAnimWidget();
    }
    if (state.isEmpty) {
      return buildNoLoadoutsBody(context);
    }
    return MultiSectionScrollView(
      [
        IntrinsicHeightScrollSection(
          itemBuilder: buildLoadout,
          itemsPerRow: MediaQueryHelper(context).responsiveValue<int>(1, tablet: 2, desktop: 3),
          itemCount: loadouts.length,
        ),
      ],
      padding: EdgeInsets.all(4),
    );
  }

  Widget buildNoLoadoutsBody(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "You have no loadouts yet. Create your first one.".translate(context).toUpperCase(),
                textAlign: TextAlign.center,
              ),
              Container(height: 16),
              ElevatedButton(
                onPressed: bloc.createNew,
                child: Text("Create Loadout".translate(context)),
              )
            ]));
  }

  Widget buildLoadout(BuildContext context, int index) {
    final loadout = state.loadouts?[index];
    if (loadout == null) return Container();
    return LoadoutListItemWidget(
      loadout,
      onAction: (action) => bloc.onItemAction(action, loadout),
    );
  }
}
