import 'dart:math';
import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_slot.widget.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/intrinsic_height_scrollable_section.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'edit_loadout.bloc.dart';

class EditLoadoutView extends StatelessWidget {
  final EditLoadoutBloc bloc;
  final EditLoadoutBloc state;
  EditLoadoutView(
    this.bloc,
    this.state, {
    Key? key,
  }) : super(key: key);

  Color get backgroundColor {
    return Colors.transparent;
    // final emblemDefinition = state.emblemDefinition;
    // final bgColor = emblemDefinition?.backgroundColor;
    // final background = Theme.of(context).colorScheme.background;
    // if (bgColor == null) return background;
    // return Color.lerp(bgColor.toMaterialColor(), background, .5) ?? background;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: buildAppBar(context),
      body: Column(children: [
        Expanded(
          child: Stack(
            children: [
              buildBody(context),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        child: NotificationsWidget(),
                      ),
                      BusyIndicatorLineWidget(),
                    ],
                  ))
            ],
          ),
        ),
        buildFooter(context),
      ]),
    );
  }

  AppBar buildAppBar(BuildContext context) => AppBar(
        title: state.creating ? Text("Create Loadout".translate(context)) : Text("Edit Loadout".translate(context)),
        centerTitle: false,
        flexibleSpace: buildAppBarBackground(context),
      );

  Widget buildAppBarBackground(BuildContext context) {
    final emblemDefinition = context.definition<DestinyInventoryItemDefinition>(state.emblemHash);
    if (emblemDefinition == null) return Container();
    if (emblemDefinition.secondarySpecial?.isEmpty ?? true) return Container();
    return Container(
        constraints: const BoxConstraints.expand(),
        child: QueuedNetworkImage(
            imageUrl: BungieApiService.url(emblemDefinition.secondarySpecial),
            fit: BoxFit.cover,
            alignment: const Alignment(-.8, 0)));
  }

  Widget buildBody(BuildContext context) {
    final screenPadding = MediaQuery.of(context).padding;

    return Material(
      child: MultiSectionScrollView(
        [
          IntrinsicHeightScrollSection(
            itemCount: 1,
            itemBuilder: (context, _) => buildNameTextField(context),
          ),
          IntrinsicHeightScrollSection(
            itemCount: 1,
            itemBuilder: (context, _) => buildSelectBackgroundButton(context),
          ),
          IntrinsicHeightScrollSection(
            itemBuilder: (context, index) => buildSlot(context, index),
            itemCount: state.bucketHashes.length,
          ),
        ],
        padding: const EdgeInsets.all(8)
            .copyWith(top: 0, left: max(screenPadding.left, 8), right: max(screenPadding.right, 8)),
      ),
    );
  }

  Widget buildNameTextField(BuildContext context) {
    return Container(
        key: Key("textfieldvalue loaded ${state.loading}"),
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          autocorrect: false,
          initialValue: state.loadoutName,
          onChanged: (value) => bloc.loadoutName = value,
          decoration: InputDecoration(labelText: context.translate("Loadout Name")),
        ));
  }

  Widget buildSelectBackgroundButton(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          child: Text("Select Loadout Background".translate(context)),
          onPressed: () => bloc.openBackgroundEmblemSelect(),
        ));
  }

  Widget buildSlot(BuildContext context, int index) {
    final bucketHash = state.bucketHashes[index];
    final slot = state.getLoadoutIndexSlot(bucketHash);

    return LoadoutSlotWidget(
      bucketHash,
      key: Key("loadout_slot_$bucketHash"),
      slot: slot,
      availableClasses: state.availableClasses,
      onItemTap: (action) {
        bloc.onSlotAction(
          bucketHash,
          equipped: action.equipped,
          classType: action.classType,
          loadoutItem: action.item,
        );
      },
    );
  }

  Widget buildFooter(BuildContext context) {
    return Material(
        elevation: 1,
        color: context.theme.secondarySurfaceLayers,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: buildAppBarBackground(context)),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                height: kToolbarHeight,
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  child: Text("Save Loadout".translate(context)),
                  onPressed: () => bloc.save(),
                ),
              ),
              BusyIndicatorBottomGradientWidget(),
            ])
          ],
        ));
  }
}
