import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/modals/base_list_bottom_sheet.base.dart';

abstract class BaseItemSelectionBottomSheet<ReturnType> extends BaseListBottomSheet<ReturnType> {
  const BaseItemSelectionBottomSheet({Key? key}) : super(key: key);

  @override
  Widget? buildListItem(BuildContext context, int index) {
    final label = buildItemLabel(context, index);
    if (label == null) return null;
    return Container(
      margin: EdgeInsets.all(4),
      child: Material(
        borderRadius: BorderRadius.circular(4),
        color: context.theme.surfaceLayers.layer3,
        child: InkWell(
          child: Container(
            padding: EdgeInsets.all(8),
            child: DefaultTextStyle(child: label, style: context.textTheme.button),
          ),
          onTap: () => Navigator.of(context).pop(indexToValue(index)),
        ),
      ),
    );
  }

  ReturnType? indexToValue(int index);

  Future<ReturnType?> show(BuildContext context) {
    return showModalBottomSheet(context: context, builder: (context) => this);
  }
}
