import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/center_icon_workaround.dart';

class ItemTagWidget extends StatelessWidget {
  final ItemNotesTag tag;
  final double fontSize;
  final bool includeLabel;
  final bool fullWidth;
  final Widget? trailing;
  final Function? onClick;
  final double padding;
  const ItemTagWidget(this.tag,
      {this.includeLabel = false,
      this.fullWidth = false,
      this.fontSize = 16,
      this.padding = 2,
      this.trailing,
      this.onClick})
      : super();

  @override
  Widget build(BuildContext context) {
    return buildBg(context, buildContents(context));
  }

  Widget buildContents(BuildContext context) {
    final trailing = this.trailing;
    if (includeLabel) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildIcon(context),
          fullWidth
              ? Expanded(child: buildLabel(context))
              : Flexible(child: buildLabel(context)),
          if (trailing != null) trailing
        ],
      );
    }
    return buildIcon(context);
  }

  Widget buildLabel(BuildContext context) {
    final style = TextStyle(
        color: tag.foregroundColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w500);
    var tagName = tag.name.isNotEmpty ? tag.name : null;
    if (tag.custom && tagName != null) {
      return Container(
          padding: EdgeInsets.symmetric(horizontal: padding * 2),
          child: Text(
            tag.name.toUpperCase(),
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: style,
          ));
    }
    return Container(
        padding: EdgeInsets.symmetric(horizontal: padding * 2),
        child: TranslatedTextWidget(
          tagName ?? "Untitled",
          uppercase: true,
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: style,
        ));
  }

  String getTagName(BuildContext context, ItemNotesTag tag) {
    final useCustomName = tag.custom && tag.name.isNotEmpty;
    if (useCustomName) return tag.name;
    if (tag.custom) return 'Untitled'.translate(context);
    final defaultLabel = tag.defaultTagType?.getLabel(context);
    if (defaultLabel != null) {
      return defaultLabel;
    }
    return tag.name.translate(context);
  }

  Widget buildIcon(BuildContext context) {
    var icon = tag.iconData;
    if (icon == null) return Container();
    return Container(
        alignment: Alignment.center,
        width: fontSize * 1.2,
        height: fontSize * 1.2,
        child: CenterIconWorkaround(icon,
            color: tag.foregroundColor, size: fontSize));
  }

  Widget buildBg(BuildContext context, Widget contents) {
    if (onClick != null) {
      return Material(
        color: tag.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(fontSize),
          side: BorderSide(
              color: tag.foregroundColor ?? Colors.transparent, width: 1),
        ),
        child: InkWell(
            onTap: () {
              onClick?.call();
            },
            child:
                Container(padding: EdgeInsets.all(padding), child: contents)),
      );
    }
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: tag.foregroundColor ?? Colors.transparent, width: 1),
            color: tag.backgroundColor,
            borderRadius: BorderRadius.circular(fontSize)),
        padding: EdgeInsets.all(padding),
        child: contents);
  }
}
