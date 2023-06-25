import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/modules/item_tags/blocs/select_tags.bloc.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/tags/tag_pill.widget.dart';

class SelectTagsView extends StatelessWidget {
  final SelectTagsBloc bloc;
  final SelectTagsBloc state;

  const SelectTagsView({Key? key, required this.bloc, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildRemoveTags(context),
        buildAddTags(context),
        buildAction(context),
      ],
    );
  }

  Widget buildRemoveTags(BuildContext context) {
    final tagsToRemove = state.tagsToRemove;
    if (tagsToRemove.isEmpty) return Container();
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          HeaderWidget(
            child: Text(
              "Remove tags".translate(context).toUpperCase(),
            ),
          ),
          SizedBox(height: 8),
          ...tagsToRemove.map((t) => buildTag(context, t, remove: true))
        ],
      ),
    );
  }

  Widget buildAddTags(BuildContext context) {
    final tagsToAdd = state.tagsToAdd;
    if (tagsToAdd.isEmpty) return Container();
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          HeaderWidget(
            child: Text(
              "Add tags".translate(context).toUpperCase(),
            ),
          ),
          SizedBox(height: 8),
          ...tagsToAdd.map((t) => buildTag(context, t))
        ],
      ),
    );
  }

  Widget buildTag(BuildContext context, ItemNotesTag tag, {bool remove = false}) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: TagPillWidget.fromTag(
              tag,
              expand: true,
              onRemove: remove ? () => bloc.remove(tag) : null,
              onTap: !remove ? () => bloc.add(tag) : null,
            ),
          ),
          if (tag.custom) buildEditButton(context, tag),
          if (tag.custom) buildDeleteButton(context, tag),
        ],
      ),
    );
  }

  Widget buildEditButton(BuildContext context, ItemNotesTag tag) {
    return buildButton(
      context,
      FontAwesomeIcons.solidPenToSquare,
      context.theme.primaryLayers,
      onTap: () => bloc.edit(tag),
    );
  }

  Widget buildDeleteButton(BuildContext context, ItemNotesTag tag) {
    return buildButton(
      context,
      FontAwesomeIcons.trash,
      context.theme.errorLayers,
      onTap: () => bloc.delete(tag),
    );
  }

  Widget buildButton(BuildContext context, IconData icon, Color color, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(left: 4),
      child: Stack(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: color,
          ),
          child: Icon(
            icon,
            size: 16,
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: CircleBorder(),
              onTap: onTap,
            ),
          ),
        ),
      ]),
    );
  }

  Widget buildAction(BuildContext context) {
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
                  onPressed: bloc.create,
                  child: Text("Create".translate(context)),
                ),
              )
            ],
          )),
    );
  }
}
