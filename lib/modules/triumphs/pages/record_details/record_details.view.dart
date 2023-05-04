import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/triumphs/pages/record_details/record_details.bloc.dart';
import 'package:little_light/modules/triumphs/widgets/details_record_description.widget.dart';
import 'package:little_light/modules/triumphs/widgets/details_record_lore.widget.dart';
import 'package:little_light/modules/triumphs/widgets/details_record_objectives.widget.dart';
import 'package:little_light/modules/triumphs/widgets/details_record_progress.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/selection/selected_items.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class RecordDetailsView extends StatelessWidget {
  final RecordDetailsBloc bloc;
  final RecordDetailsBloc state;
  final SelectionBloc selectionState;

  RecordDetailsView(this.bloc, this.state, this.selectionState);

  @override
  Widget build(BuildContext context) {
    return buildPortrait(context);
  }

  Widget buildPortrait(BuildContext context) {
    final footer = buildFooter(context);
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  buildBody(context, hasFooter: footer != null),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    right: 0,
                    child: buildNotificationWidget(context, hasFooter: footer != null),
                  ),
                ],
              ),
            ),
            footer,
          ].whereType<Widget>().toList()),
    );
  }

  Widget buildBody(BuildContext context, {required bool hasFooter}) {
    return CustomScrollView(
      slivers: [
        buildDescription(context),
        buildIntervalObjectives(context),
        buildObjectives(context),
        buildLore(context),
        buildEmptySpace(context, hasFooter: hasFooter),
      ].whereType<Widget>().toList(),
    );
  }

  Widget buildNotificationWidget(BuildContext context, {required bool hasFooter}) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final useLoadingFooter = bottomPadding > 0 && !hasFooter;
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomRight,
          child: const NotificationsWidget(),
          padding: EdgeInsets.all(8),
        ),
        useLoadingFooter
            ? SizedBox(height: bottomPadding, child: BusyIndicatorBottomGradientWidget())
            : BusyIndicatorLineWidget()
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: ManifestText<DestinyRecordDefinition>(state.recordHash),
      centerTitle: false,
    );
  }

  Widget? buildDescription(BuildContext context) {
    final recordHash = state.recordHash;
    return SliverToBoxAdapter(
      child: DetailsRecordDescriptionWidget(recordHash),
    );
  }

  Widget? buildIntervalObjectives(BuildContext context) {
    final recordHash = state.recordHash;
    final definition = context.definition<DestinyRecordDefinition>(recordHash);
    final intervalObjectives = definition?.intervalInfo?.intervalObjectives;
    if (intervalObjectives == null || intervalObjectives.isEmpty) return null;

    return SliverToBoxAdapter(
      child: DetailsRecordProgressWidget(
        recordHash,
        progress: state.progress,
        characters: state.characters,
      ),
    );
  }

  Widget? buildObjectives(BuildContext context) {
    final recordHash = state.recordHash;
    final definition = context.definition<DestinyRecordDefinition>(recordHash);
    final objectiveHashes = definition?.objectiveHashes;
    if (objectiveHashes == null || objectiveHashes.isEmpty) return null;
    return SliverToBoxAdapter(
      child: DetailsRecordObjectivesWidget(
        recordHash,
        progress: state.progress,
        characters: state.characters,
      ),
    );
  }

  Widget? buildLore(BuildContext context) {
    final recordHash = state.recordHash;
    return SliverToBoxAdapter(
      child: DetailsRecordLoreWidget(recordHash),
    );
  }

  Widget buildEmptySpace(BuildContext context, {required bool hasFooter}) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 64 + (!hasFooter ? bottomPadding : 0),
      ),
    );
  }

  Widget? buildFooter(BuildContext context) {
    final mqPadding = MediaQuery.of(context).viewPadding;
    final selection = selectionState.selectedItems;
    if (selection.isNotEmpty) {
      return Container(
          color: context.theme.surfaceLayers.layer1,
          child: Column(
            children: [
              SelectedItemsWidget(),
              SizedBox(
                height: mqPadding.bottom,
                child: BusyIndicatorBottomGradientWidget(),
              ),
            ],
          ));
    }
    return null;
  }
}
