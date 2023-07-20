import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'edit_item_notes.bloc.dart';

class EditItemNotesView extends StatelessWidget {
  final EditItemNotesBloc bloc;
  final EditItemNotesBloc state;

  const EditItemNotesView({Key? key, required this.bloc, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildContent(context),
        buildActions(context),
      ],
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
                  style: ElevatedButton.styleFrom(backgroundColor: context.theme.errorLayers),
                  onPressed: bloc.cancel,
                  child: Text("Cancel".translate(context)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: bloc.save,
                  child: Text("Save".translate(context)),
                ),
              )
            ],
          )),
    );
  }

  Widget buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12).copyWith(top: 0, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: state.customName,
            onChanged: (value) => bloc.customName = value,
            decoration: InputDecoration(label: Text("Nickname".translate(context))),
            textInputAction: TextInputAction.next,
          ),
          TextFormField(
            initialValue: state.itemNotes,
            maxLines: 3,
            minLines: 1,
            onChanged: (value) => bloc.itemNotes = value,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              label: Text("Notes".translate(context)),
              hintText: "No notes added yet".translate(context),
            ),
          ),
        ],
      ),
    );
  }
}
