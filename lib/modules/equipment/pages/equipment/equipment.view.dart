import 'package:flutter/material.dart';
import 'package:little_light/modules/equipment/pages/equipment/equipment.view.portrait.dart';
import 'package:little_light/shared/utils/helpers/bucket_type_groups.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';

import 'equipment.bloc.dart';
import 'equipment.view.landscape.dart';

class EquipmentView extends StatelessWidget {
  final EquipmentBloc bloc;
  final EquipmentBloc state;

  const EquipmentView(
    this.bloc,
    this.state, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final characters = state.characters;
    if (characters == null) return Container();
    final characterCount = characters.length;
    return PageStorage(
      bucket: state.pageStorageBucket,
      child: CustomTabControllerBuilder(
        EquipmentBucketGroup.values.length,
        builder: (context, typeTabController) => CustomTabControllerBuilder(
          characterCount,
          builder: (context, characterTabController) =>
              buildSpecificLayout(context, typeTabController, characterTabController),
        ),
      ),
    );
  }

  Widget buildSpecificLayout(
      BuildContext context, CustomTabController typeTabController, CustomTabController characterTabController) {
    if (context.mediaQuery.isLandscape || context.mediaQuery.laptopOrBigger) {
      return EquipmentLandscapeView(bloc, state, characterTabController: characterTabController);
    }
    return EquipmentPortraitView(
      bloc,
      state,
      characterTabController: characterTabController,
      typeTabController: typeTabController,
    );
  }
}
