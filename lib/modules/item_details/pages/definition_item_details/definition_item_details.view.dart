import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/item_details/views/base_item_details.view.dart';
import 'package:little_light/modules/item_details/widgets/details_wishlist_builds.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_wishlist_notes.widget.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';

class DefinitionItemDetailsView extends BaseItemDetailsView {
  DefinitionItemDetailsView(
      ItemDetailsBloc bloc, ItemDetailsBloc state, SocketControllerBloc socketState, SelectionBloc selectionState)
      : super(bloc, state, socketState, selectionState);

  @override
  Widget? buildLockState(BuildContext context) => null;
  @override
  Widget? buildActions(BuildContext context) => null;

  @override
  Widget? buildItemNotes(BuildContext context) => null;

  @override
  Widget? buildItemTags(BuildContext context) => null;

  @override
  Widget? buildWishlistBuilds(BuildContext context) {
    final builds = state.wishlistBuilds;
    if (builds == null || builds.isEmpty) return null;
    return SliverToBoxAdapter(
        child: DetailsWishlistBuildsWidget(
      builds,
      allSelectedPlugHashes: socketState.allSelectedPlugHashes,
      allEquippedPlugHashes: socketState.allEquippedPlugHashes,
      viewAllBuilds: true,
      enableViewAllBuilds: false,
    ));
  }

  @override
  Widget? buildWishlistNotes(BuildContext context) {
    final notes = state.wishlistNotes;
    if (notes == null || notes.isEmpty) return null;
    return SliverToBoxAdapter(
        child: DetailsWishlistNotesWidget(
      notes,
      viewAllNotes: true,
      enableViewAllNotes: false,
    ));
  }
}
