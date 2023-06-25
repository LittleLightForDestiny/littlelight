import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/scroll_area_type.dart';
import 'package:provider/provider.dart';

class DividerIndicatorOverlay extends StatelessWidget {
  final ScrollAreaType? top;
  final ScrollAreaType? bottom;
  final int? threshold;
  final bool topActive;
  final bool bottomActive;

  const DividerIndicatorOverlay({
    Key? key,
    this.top,
    this.bottom,
    this.threshold,
    this.topActive = false,
    this.bottomActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: buildScrollSections(context),
    );
  }

  Widget buildScrollSections(BuildContext context) {
    final top = this.top ?? context.select<UserSettingsBloc, ScrollAreaType>((settings) => settings.topScrollArea);
    final bottom =
        this.bottom ?? context.select<UserSettingsBloc, ScrollAreaType>((settings) => settings.bottomScrollArea);
    final threshold =
        this.threshold ?? context.select<UserSettingsBloc, int>((settings) => settings.scrollAreaDividerThreshold);
    if (top == bottom || threshold >= 100) return buildScrollSection(context, top, topActive);
    if (threshold <= 0) return buildScrollSection(context, bottom, bottomActive);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(flex: threshold, child: buildScrollSection(context, top, topActive)),
        Flexible(flex: 100 - threshold, child: buildScrollSection(context, bottom, bottomActive))
      ],
    );
  }

  Widget buildScrollSection(BuildContext context, ScrollAreaType type, bool isActive) {
    final color = isActive ? context.theme.primaryLayers : context.theme.onSurfaceLayers;
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: color),
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(.5),
            context.theme.surfaceLayers.withOpacity(0.5),
            color.withOpacity(.5),
          ],
          stops: [0, .5, 1],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        type.label(context).toUpperCase(),
        style: context.textTheme.title,
      ),
    );
  }
}
