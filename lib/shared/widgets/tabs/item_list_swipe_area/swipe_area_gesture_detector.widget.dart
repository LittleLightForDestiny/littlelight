import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/scroll_area_type.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:provider/provider.dart';

class SwipeAreaGestureDetector extends StatelessWidget {
  final Map<ScrollAreaType, CustomTabController> controllers;

  const SwipeAreaGestureDetector(
    this.controllers, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final top = context.select<UserSettingsBloc, ScrollAreaType>((settings) => settings.topScrollArea);
    final bottom = context.select<UserSettingsBloc, ScrollAreaType>((settings) => settings.bottomScrollArea);
    final threshold = context.select<UserSettingsBloc, int>((settings) => settings.scrollAreaDividerThreshold);
    if (top == bottom || threshold >= 100) return buildScrollSection(context, top);
    if (threshold <= 0) return buildScrollSection(context, bottom);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(flex: threshold, child: buildScrollSection(context, top)),
        Flexible(flex: 100 - threshold, child: buildScrollSection(context, bottom))
      ],
    );
  }

  Widget buildScrollSection(BuildContext context, ScrollAreaType type) {
    final controller = controllers[type];
    if (controller == null) return Container();
    return CustomTabGestureDetector(
      controller: controller,
    );
  }
}
