import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/scroll_area_type.dart';
import 'package:provider/provider.dart';

class DividerIndicatorOverlay extends StatelessWidget {
  final ScrollAreaType? top;
  final ScrollAreaType? bottom;
  final int? threshold;
  final Map<ScrollAreaType, bool>? activeTypes;
  final bool? enabled;

  const DividerIndicatorOverlay({
    Key? key,
    this.top,
    this.bottom,
    this.threshold,
    this.activeTypes,
    this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final enabled =
        this.enabled ?? context.select<UserSettingsBloc, bool>((settings) => settings.scrollAreasHintEnabled);
    if (!enabled) return Container();
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
    final isActive = activeTypes?[type] ?? false;
    final color =
        isActive ? context.theme.primaryLayers.layer2.withOpacity(.7) : context.theme.onSurfaceLayers.withOpacity(.2);
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: color),
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0),
            color,
          ],
          stops: [0, .5, 1],
        ),
      ),
      alignment: Alignment.center,
      child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: context.theme.surfaceLayers.layer0,
          ),
          child: Text(
            type.label(context).toUpperCase(),
            style: context.textTheme.title.copyWith(color: color.withOpacity(1)),
          )),
    );
  }
}
