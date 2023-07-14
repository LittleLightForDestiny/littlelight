import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_small_list_item.widget.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';

typedef OnSelectLoadout = void Function(LoadoutItemIndex);

class DetailsItemLoadoutsWidget extends StatelessWidget {
  final List<LoadoutItemIndex>? loadouts;
  final OnSelectLoadout? onSelectLoadout;
  final VoidCallback? onAddToLoadout;
  const DetailsItemLoadoutsWidget({
    Key? key,
    this.onSelectLoadout,
    this.onAddToLoadout,
    this.loadouts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Loadouts".translate(context).toUpperCase()),
          persistenceID: 'details item loadouts',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...buildLoadouts(context),
          buildAddToLoadoutButton(context),
        ],
      ),
    );
  }

  List<Widget> buildLoadouts(BuildContext context) {
    final loadouts = this.loadouts;
    if (loadouts == null) return [];
    return loadouts
        .map((l) => LoadoutSmallListItemWidget(
              l,
              onTap: () => onSelectLoadout?.call(l),
            ))
        .toList();
  }

  Widget buildAddToLoadoutButton(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onAddToLoadout,
          child: Text(
            "Add to Loadout".translate(context),
          ),
        ),
      );
}
