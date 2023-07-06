import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/containers/menu_box_title.dart';
import 'package:little_light/shared/widgets/tags/tag_icon.widget.dart';
import 'package:little_light/shared/widgets/tags/tag_pill.widget.dart';
import 'edit_tag.bloc.dart';

const _gridHeight = 144.0;

typedef OnColorSelect = void Function(Color color);
typedef OnIconSelect = void Function(ItemTagIcon icon);

class EditTagView extends StatelessWidget {
  final EditTagBloc bloc;
  final EditTagBloc state;

  const EditTagView({
    Key? key,
    required this.bloc,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      buildPreview(context),
      Flexible(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(8).copyWith(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildNameField(context),
                SizedBox(height: 16),
                MenuBox(
                  child: Column(
                    children: [
                      MenuBoxTitle("Background color".translate(context)),
                      buildBackgroundColors(context),
                    ],
                  ),
                ),
                MenuBox(
                  child: Column(
                    children: [
                      MenuBoxTitle("Text/icon color".translate(context)),
                      buildForegroundColors(context),
                    ],
                  ),
                ),
                MenuBox(
                  child: Column(
                    children: [
                      MenuBoxTitle("Tag icon".translate(context)),
                      buildIcons(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      buildActions(context),
    ]));
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

  Widget buildPreview(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          TagIconWidget.fromTag(bloc.tag),
          SizedBox(width: 8),
          Flexible(child: TagPillWidget.fromTag(bloc.tag)),
        ]));
  }

  Widget buildNameField(BuildContext context) {
    return TextFormField(
      initialValue: state.tagName,
      onChanged: (value) => bloc.tagName = value,
      decoration: InputDecoration(label: Text("Tag name".translate(context)), hintText: "Untitled".translate(context)),
      maxLength: 20,
    );
  }

  Widget buildBackgroundColors(BuildContext context) {
    return SizedBox(
        height: _gridHeight,
        child: GridView.count(
          shrinkWrap: false,
          scrollDirection: Axis.horizontal,
          crossAxisCount: 3,
          children: bloc.backgroundColors
              .map(
                (c) => buildButton(
                  context,
                  backgroundColor: c,
                  selected: c == bloc.backgroundColor,
                  onTap: () => bloc.backgroundColor = c,
                ),
              )
              .toList(),
        ));
  }

  Widget buildForegroundColors(BuildContext context) {
    return SizedBox(
        height: _gridHeight,
        child: GridView.count(
          shrinkWrap: false,
          scrollDirection: Axis.horizontal,
          crossAxisCount: 3,
          children: bloc.foregroundColors
              .map(
                (c) => buildButton(
                  context,
                  foregroundColor: c,
                  selected: c == bloc.foregroundColor,
                  onTap: () => bloc.foregroundColor = c,
                ),
              )
              .toList(),
        ));
  }

  Widget buildIcons(BuildContext context) {
    return SizedBox(
        height: _gridHeight,
        child: GridView.count(
          shrinkWrap: false,
          scrollDirection: Axis.horizontal,
          crossAxisCount: 3,
          children: bloc.icons
              .map((i) => buildButton(
                    context,
                    icon: i,
                    selected: bloc.icon == i,
                    onTap: () => bloc.icon = i,
                  ))
              .toList(),
        ));
  }

  Widget buildButton(
    BuildContext context, {
    ItemTagIcon? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    bool selected = false,
    VoidCallback? onTap,
  }) =>
      AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(width: 2, color: selected ? context.theme.onSurfaceLayers : Colors.transparent),
          ),
          margin: const EdgeInsets.all(1),
          child: Material(
            borderRadius: BorderRadius.circular(2),
            color: backgroundColor ?? state.backgroundColor,
            child: InkWell(
              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              child: Icon(
                icon?.iconData ?? bloc.iconData,
                color: foregroundColor ?? bloc.foregroundColor,
              ),
              onTap: onTap,
            ),
          ),
        ),
      );
}
