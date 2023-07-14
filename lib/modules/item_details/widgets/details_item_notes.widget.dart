import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';

class DetailsItemNotesWidget extends StatelessWidget {
  final String? customName;
  final String? notes;
  final VoidCallback? onEditTap;

  const DetailsItemNotesWidget({Key? key, this.customName, this.notes, this.onEditTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Item Notes".translate(context).toUpperCase()),
          persistenceID: 'item notes',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildCustomName(context),
          Container(height: 8),
          buildNotes(context),
          Container(height: 8),
          ElevatedButton(onPressed: onEditTap, child: Text("Edit".translate(context))),
        ],
      ),
    );
  }

  Widget buildField(BuildContext context, String label, String value, {double? minHeight}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            padding: EdgeInsets.all(4),
            child: Text(
              label,
              style: context.textTheme.caption,
            )),
        Container(
          constraints: BoxConstraints(minHeight: minHeight ?? 0),
          decoration: BoxDecoration(
            color: context.theme.surfaceLayers.layer2,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.all(4),
          child: Text(
            value,
            style: context.textTheme.body,
          ),
        )
      ],
    );
  }

  Widget buildCustomName(BuildContext context) {
    return buildField(
      context,
      "Nickname".translate(context),
      customName ?? "Not set".translate(context),
    );
  }

  Widget buildNotes(BuildContext context) {
    return buildField(
      context,
      "Notes".translate(context),
      notes ?? "No notes added yet".translate(context),
      minHeight: 64,
    );
  }
}
