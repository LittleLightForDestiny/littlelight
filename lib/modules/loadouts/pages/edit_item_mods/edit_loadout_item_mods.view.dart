import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/edit_item_mods/edit_loadout_item_mods.bloc.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

class EditLoadoutItemModsView extends StatelessWidget {
  EditLoadoutItemModsBloc _state(BuildContext context) => context.watch<EditLoadoutItemModsBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    final categories = _state(context).categories;
    if (categories == null) return Container();
    return Column(
      children: categories //
          .map((e) => ManifestText<DestinySocketCategoryDefinition>(e.socketCategoryHash!))
          .toList(),
    );
  }
}
