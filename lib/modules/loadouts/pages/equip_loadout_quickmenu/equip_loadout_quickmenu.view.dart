import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_small_list_item.widget.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';

import 'equip_loadout_quickmenu.bloc.dart';

class LoadoutItemOptionsView extends StatelessWidget {
  final EquipLoadoutQuickmenuBloc bloc;
  final EquipLoadoutQuickmenuBloc state;

  const LoadoutItemOptionsView({
    Key? key,
    required this.bloc,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildHeader(context),
        Flexible(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [buildLoadoutList(context)],
              )),
        ),
      ],
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: HeaderWidget(
        child: Text(
          (state.equip ? "Equip Loadout".translate(context) : "Transfer Loadout".translate(context)).toUpperCase(),
        ),
      ),
    );
  }

  Widget buildLoadoutList(BuildContext context) {
    final loadouts = state.loadouts;
    if (loadouts == null) return Container(height: 256, child: LoadingAnimWidget());
    return Column(children: loadouts.map((e) => LoadoutSmallListItemWidget(e)).toList());
  }
}
