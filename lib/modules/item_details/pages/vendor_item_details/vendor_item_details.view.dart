import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/item_details/views/base_item_details.view.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';

class VendorItemDetailsView extends BaseItemDetailsView {
  VendorItemDetailsView(
      ItemDetailsBloc bloc, ItemDetailsBloc state, SocketControllerBloc socketState, SelectionBloc selectionState)
      : super(bloc, state, socketState, selectionState);

  @override
  Widget? buildItemNotes(BuildContext context) => null;

  @override
  Widget? buildItemTags(BuildContext context) => null;
}
