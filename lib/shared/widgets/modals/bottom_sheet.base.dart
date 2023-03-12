import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';

abstract class BaseItemSelectionBottomSheet<ReturnType> extends StatelessWidget {
  const BaseItemSelectionBottomSheet({Key? key}) : super(key: key);

  int? get itemCount;

  @override
  Widget build(BuildContext context) {
    final header = this.buildHeader(context);
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      if (header != null)
        Container(
          padding: EdgeInsets.all(8),
          child: HeaderWidget(child: header),
        ),
      Flexible(child: buildList(context)),
    ]);
  }

  Widget? buildHeader(BuildContext context);

  Widget buildList(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      itemBuilder: (context, index) => buildAttributeButton(context, index),
      padding: EdgeInsets.all(8) + EdgeInsets.only(bottom: mq.viewPadding.bottom),
    );
  }

  Widget? buildAttributeButton(BuildContext context, int index) {
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

  Widget? buildItemLabel(BuildContext context, int index);

  ReturnType? indexToValue(int index);

  Future<ReturnType?> show(BuildContext context) {
    return showModalBottomSheet(context: context, builder: (context) => this);
  }
}
