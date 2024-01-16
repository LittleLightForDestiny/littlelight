import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/modules/loadouts/widgets/destiny_loadout_list_item.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';

import 'save_destiny_loadout_quickmenu.bloc.dart';

class SaveDestinyLoadoutQuickmenuView extends StatelessWidget {
  final SaveDestinyLoadoutQuickmenuBloc bloc;
  final SaveDestinyLoadoutQuickmenuBloc state;

  const SaveDestinyLoadoutQuickmenuView({
    Key? key,
    required this.bloc,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: context.mediaQuery.size.height * .8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          Flexible(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [buildLoadoutList(context)],
                )),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: HeaderWidget(
        child: Text("Save Loadout".translate(context)),
      ),
    );
  }

  Widget buildLoadoutList(BuildContext context) {
    final destinyLoadouts = state.destinyLoadouts ?? <DestinyLoadoutInfo>[];
    return Column(children: [
      ...destinyLoadouts.map((loadout) => Container(
            padding: EdgeInsets.all(4),
            child: DestinyLoadoutListItemWidget(
              loadout,
              onTap: () => bloc.saveLoadout(loadout),
              onLongPress: () => bloc.editLoadout(loadout),
            ),
          ))
    ]);
  }
}
