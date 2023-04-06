import 'package:flutter/material.dart';
import 'package:little_light/modules/item_details/widgets/item_details_cover.widget.dart';

import 'inventory_item_details.bloc.dart';

class InventoryItemDetailsView extends StatelessWidget {
  final InventoryItemDetailsBloc bloc;
  final InventoryItemDetailsBloc state;

  InventoryItemDetailsView(InventoryItemDetailsBloc this.bloc, InventoryItemDetailsBloc this.state);

  @override
  Widget build(BuildContext context) {
    return buildPortrait(context);
  }

  Widget buildPortrait(BuildContext context) {
    final hash = state.itemHash;
    if (hash == null) return Container();
    return Scaffold(
      body: CustomScrollView(slivers: [
        ItemDetailsCoverWidget(
          item: state.item,
        ),
      ]),
    );
  }
}
