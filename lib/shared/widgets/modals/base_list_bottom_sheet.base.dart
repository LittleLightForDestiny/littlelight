import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';

abstract class BaseListBottomSheet<ReturnType> extends StatelessWidget {
  const BaseListBottomSheet({Key? key}) : super(key: key);

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

  Future<ReturnType?> show(BuildContext context) async {
    final result = await showModalBottomSheet(context: context, builder: (context) => this);
    if (result is ReturnType) return result;
    return null;
  }

  Widget? buildItemLabel(BuildContext context, int index);
}
