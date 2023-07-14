import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_small_list_item.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';

import 'add_to_loadout_quickmenu.bloc.dart';

class AddToLoadoutQuickMenuView extends StatelessWidget {
  final AddToLoadoutQuickmenuBloc bloc;
  final AddToLoadoutQuickmenuBloc state;

  const AddToLoadoutQuickMenuView({
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
          buildOptions(context),
          Flexible(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(8).copyWith(
                  top: 0,
                  bottom: context.mediaQuery.padding.bottom,
                ),
                scrollDirection: Axis.vertical,
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
        child: Text(
          "Add to Loadout".translate(context).toUpperCase(),
        ),
      ),
    );
  }

  Widget buildOptions(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: context.mediaQuery.tabletOrBigger
            ? IntrinsicHeight(
                child: Row(children: [
                Expanded(child: buildFreeSlotsSlider(context)),
              ]))
            : Column(children: [
                buildFreeSlotsSlider(context),
              ]));
  }

  Widget buildFreeSlotsSlider(BuildContext context) {
    return MenuBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.theme.surfaceLayers.layer1,
            ),
            child: Row(children: [
              Expanded(
                  child: Text(
                "As equipped item".translate(context),
                style: context.textTheme.highlight,
              )),
              LLSwitch.callback(state.asEquipped, (value) => bloc.asEquipped = value)
            ]),
          ),
        ],
      ),
    );
  }

  Widget buildLoadoutList(BuildContext context) {
    final loadouts = state.loadouts;
    if (loadouts == null) return Container(height: 256, child: LoadingAnimWidget());
    return Column(
        children: loadouts
            .map((e) => LoadoutSmallListItemWidget(
                  e,
                  onTap: () => bloc.loadoutSelected(e),
                ))
            .toList());
  }
}
