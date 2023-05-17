import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/item_details/views/base_item_details.view.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';

import 'edit_loadout_item_mods.bloc.dart';

class LoadoutItemDetailsView extends BaseItemDetailsView {
  LoadoutItemDetailsView(
    ItemDetailsBloc bloc,
    ItemDetailsBloc state,
    SocketControllerBloc socketState,
    SelectionBloc selectionState,
  ) : super(bloc, state, socketState, selectionState);

  @override
  Widget? buildLockState(BuildContext context) => null;

  @override
  Widget? buildActions(BuildContext context) => null;

  @override
  Widget? buildDuplicates(BuildContext context) => null;

  @override
  Widget? buildItemNotes(BuildContext context) => null;

  @override
  Widget? buildItemTags(BuildContext context) => null;

  @override
  Widget? buildLore(BuildContext context) => null;

  @override
  Widget? buildCollectibleInfo(BuildContext context) => null;

  @override
  Widget? buildItemProgress(BuildContext context) => null;

  @override
  Widget? buildQuestSteps(BuildContext context) => null;

  @override
  Widget? buildWishlistBuilds(BuildContext context) => null;

  @override
  Widget? buildWishlistInfo(BuildContext context) => null;

  @override
  Widget? buildWishlistNotes(BuildContext context) => null;

  @override
  Widget? buildFooter(BuildContext context) {
    return Container(
      color: context.theme.secondarySurfaceLayers.layer1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.all(8),
            child: ElevatedButton(
              child: Text("Save mods".translate(context)),
              onPressed: () {
                final bloc = this.bloc;
                if (bloc is LoadoutItemDetailsBloc) {
                  bloc.saveMods();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
