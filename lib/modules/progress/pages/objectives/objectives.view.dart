import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/modules/progress/pages/objectives/objectives.bloc.dart';
import 'package:little_light/modules/progress/widgets/objective_tracking_record_item.widget.dart';
import 'package:little_light/modules/progress/widgets/objective_tracking_reordering_item.widget.dart';
import 'package:little_light/modules/progress/widgets/objetive_tracking_bounty_item.widget.dart';
import 'package:little_light/modules/progress/widgets/objetive_tracking_questline_item.widget.dart';
import 'package:little_light/modules/triumphs/widgets/record_item.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/intrinsic_height_scrollable_section.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

class ObjectivesView extends StatelessWidget {
  final ObjectivesBloc bloc;
  final ObjectivesBloc state;

  const ObjectivesView(
    this.bloc,
    this.state, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            enableFeedback: false,
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          centerTitle: false,
          actions: [
            buildSmallItemOption(context),
            buildLargeItemOption(context),
            buildReorderButton(context),
          ],
          title: Text("Objectives".translate(context))),
      body: Stack(children: [
        state.reordering ? buildReorderingBody(context) : buildBody(context),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: buildNotifications(context),
        ),
      ]),
    );
  }

  Widget buildBody(BuildContext context) {
    final objectives = state.objectives;
    if (objectives == null) {
      return LoadingAnimWidget();
    }
    if (objectives.isEmpty) {
      return Container(
          padding: EdgeInsets.all(4),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "You aren't tracking any objectives yet. Add one from Triumphs or Pursuits.".translate(context),
                  textAlign: TextAlign.center,
                ),
              ]));
    }
    return MultiSectionScrollView(
      [
        IntrinsicHeightScrollSection(
            itemBuilder: (context, index) => buildItem(context, objectives[index]),
            itemCount: objectives.length,
            itemsPerRow: context.mediaQuery.responsiveValue(
              1,
              tablet: 2,
              desktop: 3,
            )),
      ],
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      padding: EdgeInsets.all(4) + context.mediaQuery.viewPadding.copyWith(top: 0),
    );
  }

  Widget buildItem(BuildContext context, TrackedObjective objective) {
    final useSmall = state.viewMode == ObjectiveViewMode.Small;
    switch (objective.type) {
      case TrackedObjectiveType.Triumph:
        final record = state.getRecord(objective);
        if (useSmall)
          return buildButton(
            context,
            objective,
            RecordItemWidget(
              objective.hash,
              progress: record,
            ),
          );
        return buildButton(
          context,
          objective,
          ObjectiveTrackingRecordItemWidget(
            objective.hash,
            progress: record,
          ),
        );
      case TrackedObjectiveType.Item:
        final item = state.getItem(objective);
        if (item == null) return Container();
        if (useSmall)
          return buildButton(
            context,
            objective,
            HighDensityInventoryItem(item),
          );
        return buildButton(
          context,
          objective,
          ObjectiveTrackingBountyItemWidget(item),
        );
      case TrackedObjectiveType.Plug:
        return Text("plug ${objective.hash}");
      case TrackedObjectiveType.Questline:
        final item = state.getItem(objective);
        if (item == null) return Container();
        if (useSmall)
          return buildButton(
            context,
            objective,
            HighDensityInventoryItem(item),
          );
        return buildButton(
          context,
          objective,
          ObjectiveTrackingQuestlineItemWidget(item),
        );
    }
  }

  Widget buildButton(BuildContext context, TrackedObjective objective, Widget child) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => bloc.openDetails(objective),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNotifications(BuildContext context) {
    final hasBottomPadding = context.mediaQuery.viewPadding.bottom > 0;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: NotificationsWidget(),
        ),
        hasBottomPadding ? BusyIndicatorBottomGradientWidget() : BusyIndicatorLineWidget(),
      ],
    );
  }

  Widget buildReorderButton(BuildContext context) => buildIconButton(
        context,
        state.reordering
            ? Icon(FontAwesomeIcons.check)
            : Transform.rotate(angle: pi / 2, child: const Icon(FontAwesomeIcons.rightLeft)),
        onTap: () => bloc.toggleReordering(),
      );

  Widget buildReorderingBody(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;

    return ReorderableList(
        itemCount: state.objectives?.length ?? 0,
        itemBuilder: (context, index) {
          return buildSortItem(context, index);
        },
        itemExtent: 72,
        padding: const EdgeInsets.all(8).copyWith(left: max(screenPadding.left, 8), right: max(screenPadding.right, 8)),
        onReorder: (oldIndex, newIndex) => bloc.reorderObjectives(oldIndex, newIndex));
  }

  Widget buildSortItem(BuildContext context, int index) {
    final objective = state.objectives?[index];
    if (objective == null) return Container();
    return Container(
        key: Key("objective-tracking-${index}"),
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: Colors.transparent,
        child: ObjectiveTrackingReorderingItemWidget(index, objective, item: state.getItem(objective)));
  }

  Widget buildSmallItemOption(BuildContext context) => buildIconButton(
        context,
        Icon(LittleLightIcons.icon_display_options_list),
        selected: state.viewMode == ObjectiveViewMode.Small,
        onTap: () => bloc.viewMode = ObjectiveViewMode.Small,
      );

  Widget buildLargeItemOption(BuildContext context) => buildIconButton(
        context,
        Icon(LittleLightIcons.icon_display_options_details),
        selected: state.viewMode == ObjectiveViewMode.Large,
        onTap: () => bloc.viewMode = ObjectiveViewMode.Large,
      );

  Widget buildIconButton(
    BuildContext context,
    Widget icon, {
    bool selected = false,
    VoidCallback? onTap,
  }) =>
      Material(
        color: selected ? context.theme.secondarySurfaceLayers.layer3 : Colors.transparent,
        child: InkWell(
          enableFeedback: false,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(8),
              child: icon,
            ),
          ),
          onTap: onTap,
        ),
      );
}
