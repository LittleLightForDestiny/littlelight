import 'package:flutter/material.dart';
import 'package:little_light/shared/views/base_presentation_node.view.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/settings/widgets/switch_option.widget.dart';
import 'package:provider/provider.dart';

abstract class BaseCollectionsView extends BasePresentationNodeView {
  const BaseCollectionsView({Key? key}) : super(key: key);

  Widget? buildEndDrawer(BuildContext context) {
    final userSettings = context.read<UserSettingsBloc>();
    return Drawer(
        child: Column(children: [
      AppBar(
        title: Text("Settings".translate(context)),
        actions: <Widget>[Container()],
        centerTitle: false,
        leading: IconButton(
          enableFeedback: false,
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            SwitchOptionWidget(
              "Hide Unavailable Items".translate(context).toUpperCase(),
              "Hide collectible items that are currently unavailable.".translate(context),
              value: userSettings.hideUnavailableCollectibles,
              onChanged: (value) => userSettings.hideUnavailableCollectibles = value,
            ),

            /// Temporarily disabled
            // SwitchOptionWidget(
            //   "Sort Newest to Oldest".translate(context).toUpperCase(),
            //   "Sort collectibles so that newest items appear first.".translate(context),
            //   value: userSettings.sortCollectiblesByNewest,
            //   onChanged: (value) => userSettings.sortCollectiblesByNewest = value,
            // ),
          ]))
    ]));
  }

  List<Widget>? buildActions(BuildContext context) {
    return [
      Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
      ),
    ];
  }
}
