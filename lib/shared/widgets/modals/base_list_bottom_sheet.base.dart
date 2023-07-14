import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';

abstract class BaseListBottomSheet<ReturnType> extends BaseBottomSheet<ReturnType> {
  const BaseListBottomSheet({Key? key}) : super(key: key);

  int? get itemCount;

  Widget? buildHeader(BuildContext context);

  Widget buildContent(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      itemBuilder: (context, index) => buildListItem(context, index),
      padding: EdgeInsets.all(8) + EdgeInsets.only(bottom: mq.viewPadding.bottom),
    );
  }

  Widget? buildListItem(BuildContext context, int index) {
    final label = buildItemLabel(context, index);
    if (label == null) return null;
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(8),
          child: DefaultTextStyle(child: label, style: context.textTheme.button),
        ),
      ),
    );
  }

  Widget? buildItemLabel(BuildContext context, int index);
}
