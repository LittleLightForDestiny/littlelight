import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_list_item.widget.dart';

import 'confirm_delete_loadout.bloc.dart';

typedef OnColorSelect = void Function(Color color);
typedef OnIconSelect = void Function(ItemTagIcon icon);

class DeleteLoadoutView extends StatelessWidget {
  final DeleteLoadoutBloc bloc;
  final DeleteLoadoutBloc state;

  const DeleteLoadoutView({
    Key? key,
    required this.bloc,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
      Flexible(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildMessage(context),
              buildPreview(context),
            ],
          ),
        ),
      ),
      buildActions(context),
    ]));
  }

  Widget buildMessage(BuildContext context) {
    final loadoutName = bloc.loadout?.name ?? "";
    final name = loadoutName.isNotEmpty ? loadoutName : "Untitled".translate(context);
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(
        "Do you really want to delete the loadout {loadoutName} ?".translate(
          context,
          replace: {"loadoutName": name},
        ),
        style: context.textTheme.body,
      ),
    );
  }

  Widget buildActions(BuildContext context) {
    return Container(
      color: context.theme.surfaceLayers.layer3,
      child: SafeArea(
          minimum: EdgeInsets.all(12),
          top: false,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: bloc.cancel,
                  child: Text("No".translate(context)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: context.theme.errorLayers),
                  onPressed: bloc.delete,
                  child: Text("Yes".translate(context)),
                ),
              )
            ],
          )),
    );
  }

  Widget buildPreview(BuildContext context) {
    final loadout = bloc.loadout;
    if (loadout == null) return Container();
    return Container(
        alignment: Alignment.center,
        child: Container(
          width: 600,
          padding: EdgeInsets.all(8),
          child: IntrinsicHeight(
            child: Container(child: LoadoutListItemWidget(loadout)),
          ),
        ));
  }
}
