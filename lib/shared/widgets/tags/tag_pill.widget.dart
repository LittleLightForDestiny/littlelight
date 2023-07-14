import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/shared/widgets/ui/center_icon_workaround.dart';

const _tagIconSize = 24.0;
const _tagLabelPadding = 4.0;

class TagPillWidget extends StatelessWidget {
  final Color? foreground;
  final Color? background;
  final IconData? icon;
  final String? tagName;
  final bool isCustom;
  final bool expand;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const TagPillWidget({
    this.icon,
    this.background,
    this.foreground,
    this.tagName,
    this.onTap,
    this.isCustom = false,
    this.expand = false,
    this.onRemove,
  }) : super();

  factory TagPillWidget.fromTag(
    ItemNotesTag tag, {
    VoidCallback? onTap,
    VoidCallback? onRemove,
    bool expand = false,
  }) {
    return TagPillWidget(
      icon: tag.iconData,
      background: tag.backgroundColor,
      foreground: tag.foregroundColor,
      tagName: tag.name,
      isCustom: tag.custom,
      onTap: onTap,
      onRemove: onRemove,
      expand: expand,
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildBg(
      context,
      buildContents(context),
    );
  }

  Widget buildContents(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildIcon(context),
        expand ? Expanded(child: buildLabel(context)) : Flexible(child: buildLabel(context)),
        if (onRemove != null) buildRemoveButton(context),
      ],
    );
  }

  Widget buildRemoveButton(BuildContext context) {
    return Stack(children: [
      Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_tagIconSize), color: context.theme.onSurfaceLayers.layer0),
          width: _tagIconSize,
          height: _tagIconSize,
          alignment: Alignment.center,
          child: CenterIconWorkaround(
            FontAwesomeIcons.solidCircleXmark,
            size: _tagIconSize - 4,
            color: context.theme.errorLayers.layer0,
          )),
      Positioned.fill(
          child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRemove,
          customBorder: CircleBorder(),
        ),
      )),
    ]);
  }

  Widget buildLabel(BuildContext context) {
    final style = context.textTheme.body.copyWith(color: foreground);
    return Container(
        padding: EdgeInsets.symmetric(horizontal: _tagLabelPadding),
        child: Text(
          getTagName(context).toUpperCase(),
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: style,
        ));
  }

  String getTagName(BuildContext context) {
    final name = tagName ?? "";
    if (isCustom && name.isEmpty) return "Untitled".translate(context);
    if (isCustom) return name;
    return name.translate(context);
  }

  Widget buildIcon(BuildContext context) {
    final icon = this.icon;
    if (icon == null) return Container();
    return Container(
        alignment: Alignment.center,
        width: _tagIconSize,
        height: _tagIconSize,
        child: CenterIconWorkaround(icon, color: foreground, size: _tagIconSize * .9));
  }

  Widget buildBg(BuildContext context, Widget contents) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_tagIconSize),
        side: BorderSide(color: foreground ?? Colors.transparent, width: 1),
      ),
      child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_tagIconSize)),
          child: Container(
            padding: EdgeInsets.all(4),
            child: contents,
          )),
    );
  }
}
