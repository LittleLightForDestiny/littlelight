import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/modules/loadouts/widgets/destiny_loadout_list_item.widget.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_list_item.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'confirm_delete_destiny_loadout.bloc.dart';

typedef OnColorSelect = void Function(Color color);
typedef OnIconSelect = void Function(ItemTagIcon icon);

class DeleteDestinyLoadoutView extends StatelessWidget {
  final DeleteDestinyLoadoutBloc bloc;
  final DeleteDestinyLoadoutBloc state;

  const DeleteDestinyLoadoutView({
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
    final loadoutName = context.definition<DestinyLoadoutNameDefinition>(state.loadout.loadout.nameHash)?.name ?? "";
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
                  onPressed: !bloc.busy ? bloc.cancel : null,
                  child: Text("No".translate(context)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: context.theme.errorLayers, disabledBackgroundColor: context.theme.errorLayers),
                  onPressed: !bloc.busy ? bloc.delete : null,
                  child: Text("Yes".translate(context)),
                ),
              )
            ],
          )),
    );
  }

  Widget buildPreview(BuildContext context) {
    final loadout = bloc.loadout;
    return Container(
        alignment: Alignment.center,
        child: Container(
          width: LoadoutListItemWidget.maxWidth,
          padding: EdgeInsets.all(8),
          child: IntrinsicHeight(
            child: Container(child: DestinyLoadoutListItemWidget(loadout)),
          ),
        ));
  }
}
