import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/shared/widgets/tags/tag_icon.widget.dart';
import 'package:little_light/shared/widgets/tags/tag_pill.widget.dart';

import 'confirm_delete_tag.bloc.dart';

typedef OnColorSelect = void Function(Color color);
typedef OnIconSelect = void Function(ItemTagIcon icon);

class DeleteTagView extends StatelessWidget {
  final DeleteTagBloc bloc;
  final DeleteTagBloc state;

  const DeleteTagView({
    Key? key,
    required this.bloc,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      buildMessage(context),
      buildPreview(context),
      buildActions(context),
    ]));
  }

  Widget buildMessage(BuildContext context) {
    final tagName = bloc.tag.name.isEmpty ? "Untitled".translate(context) : bloc.tag.name;
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(
        "Do you really want to delete the tag {tagName} ?".translate(
          context,
          replace: {"tagName": tagName},
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
    return Container(
        padding: const EdgeInsets.all(8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          TagIconWidget.fromTag(bloc.tag),
          SizedBox(width: 8),
          Flexible(child: TagPillWidget.fromTag(bloc.tag)),
        ]));
  }
}
