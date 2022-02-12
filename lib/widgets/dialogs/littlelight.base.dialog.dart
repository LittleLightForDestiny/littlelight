//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

typedef DialogWidgetBuilder = Widget Function(BuildContext context);

const _defaultInsetPaddings = EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0);

abstract class LittleLightBaseDialog extends StatelessWidget {
  final WidgetBuilder? titleBuilder;
  final WidgetBuilder? bodyBuilder;
  final WidgetBuilder? actionsBuilder;
  final double maxWidth;
  final double maxHeight;

  const LittleLightBaseDialog(
      {Key? key, this.titleBuilder, this.bodyBuilder, this.actionsBuilder, this.maxWidth = 600, this.maxHeight = 500})
      : super(key: key);

  CrossAxisAlignment get crossAxisAlignment => CrossAxisAlignment.stretch;

  EdgeInsets? getDialogInsetPaddings(BuildContext context) => _defaultInsetPaddings;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: getDialogInsetPaddings(context),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [buildTitleContainer(context), buildBodyContainer(context), buildActionsContainer(context)],
      ),
    );
  }

  Widget buildTitleContainer(BuildContext context) {
    final title = buildTitle(context);
    if (title == null) return Container();
    return Container(
      color: LittleLightTheme.of(context).surfaceLayers.layer3,
      padding: EdgeInsets.all(8),
      child: DefaultTextStyle(
        style: LittleLightTheme.of(context).textTheme.title,
        child: title,
      ),
    );
  }

  Widget buildBodyContainer(BuildContext context) {
    final body = buildBody(context);
    if (body == null) return Container();
    return Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        padding: EdgeInsets.all(16),
        child: body);
  }

  Widget buildActionsContainer(BuildContext context) {
    final actions = buildActions(context);
    if (actions == null) return Container();
    return Container(padding: EdgeInsets.all(8).copyWith(top: 0), child: actions);
  }

  Widget? buildTitle(BuildContext context) => titleBuilder?.call(context);

  Widget? buildBody(BuildContext context) => bodyBuilder?.call(context);

  Widget? buildActions(BuildContext context) => actionsBuilder?.call(context);
}
