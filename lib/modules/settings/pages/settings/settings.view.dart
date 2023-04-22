// @dart=2.9

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/modules/settings/pages/settings/settings.bloc.dart';
import 'package:little_light/modules/settings/widgets/settings_option.widget.dart';
import 'package:little_light/modules/settings/widgets/switch_option.widget.dart';
import 'package:little_light/modules/settings/widgets/wishlist_file_item.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/shared/utils/extensions/item_sort_parameter_type_data.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/ui/center_icon_workaround.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/dialogs/busy.dialog.dart';
import 'package:little_light/widgets/dialogs/tags/select_tag.dialog.dart';
import 'package:little_light/shared/widgets/tags/tag_pill.widget.dart';
import 'package:little_light/widgets/option_sheets/free_slots_slider.widget.dart';

class SettingsView extends StatefulWidget {
  final SettingsBloc _bloc;
  final SettingsBloc _state;
  const SettingsView(this._bloc, this._state, {Key key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with UserSettingsConsumer, WishlistsConsumer {
  SettingsBloc get _bloc => widget._bloc;
  SettingsBloc get _state => widget._state;
  List<ItemSortParameter> itemOrdering;
  List<ItemSortParameter> pursuitOrdering;
  Set<String> priorityTags;
  List<WishlistFile> wishlists;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings".translate(context)),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              SwitchOptionWidget(
                "Tap to select".translate(context).toUpperCase(),
                "Tapping on items will select them for quick transfer and equip instead of opening details. Hold for details."
                    .translate(context),
                value: _state.tapToSelect,
                onChanged: (value) => _bloc.tapToSelect = value,
              ),
              if (_state.canKeepAwake)
                SwitchOptionWidget(
                  "Keep Awake".translate(context).toUpperCase(),
                  "Keep device awake while the app is open.".translate(context),
                  value: _state.keepAwake,
                  onChanged: (value) => _bloc.keepAwake = value,
                ),
              SwitchOptionWidget(
                "Auto open Keyboard".translate(context).toUpperCase(),
                "Open keyboard automatically in quick search.".translate(context),
                value: _state.autoOpenKeyboard,
                onChanged: (value) => _bloc.autoOpenKeyboard = value,
              ),
              SwitchOptionWidget(
                "Enable auto transfers".translate(context).toUpperCase(),
                "If enabled, Little Light will try to move items out of the way to make room for new transfers."
                    .translate(context),
                value: _state.enabledAutoTransfers,
                onChanged: (value) => _bloc.enabledAutoTransfers = value,
              ),
              SettingsOptionWidget(
                "Default free slots".translate(context).toUpperCase(),
                Column(children: [
                  Slider(
                    min: 0,
                    max: 9,
                    value: _state.defaultFreeSlots.toDouble(),
                    onChanged: (value) => _state.defaultFreeSlots = value.floor(),
                    onChangeEnd: (value) => userSettings.saveDefaultFreeSlots(value.floor()),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                      "This is the default count of slots that should be empty after you equip or transfer a loadout, not considering the pieces in the loadout itself."
                          .translate(context))
                ]),
                trailing: Text("${_state.defaultFreeSlots}"),
              ),
              SettingsOptionWidget(
                "Wishlists".translate(context).toUpperCase(),
                Column(children: [
                  Text(
                      "You can add community curated wishlists (or your custom ones) on Little Light to check your rolls."
                          .translate(context)),
                ]),
                trailing: ElevatedButton(
                  child: Text("Add Wishlist".translate(context)),
                  onPressed: () => _bloc.addWishlist(),
                  style: ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ),
              buildWishlistsList(context),
              HeaderWidget(
                  child: Text(
                "Wishlists".translate(context).toUpperCase(),
              )),
              Container(height: 16),
              HeaderWidget(
                  child: Text(
                "Order characters by".translate(context).toUpperCase(),
              )),
              // buildCharacterOrdering(context),
              Container(height: 32),
              HeaderWidget(
                  child: Text(
                "Order items by".translate(context).toUpperCase(),
              )),
              // buildItemOrderList(context),
              HeaderWidget(
                  child: Text(
                "Order pursuits by".translate(context).toUpperCase(),
              )),
              // buildPursuitOrderList(context),
              HeaderWidget(
                  child: Text(
                "Priority Tags".translate(context).toUpperCase(),
              )),
              // buildPriorityTags(context),
              Container(height: 32),
            ])));
  }

  Future<T> showWishlistsProcessing<T>(BuildContext context, Future<T> future) {
    return Navigator.of(context)
        .push(BusyDialogRoute(context, label: Text("Processing wishlists".translate(context)), awaitFuture: future));
  }

  Widget buildWishlistsList(BuildContext context) {
    final wishlists = _bloc.wishlists;
    if (wishlists == null) return Container(height: 80, child: LoadingAnimWidget());
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: wishlists
            .map((w) => WishlistFileItem(
                  file: w,
                  onRemove: () => _bloc.removeWishlist(w),
                  isAdded: false,
                ))
            .toList());
  }

  buildDefaultFreeSlots(BuildContext context) {
    return FreeSlotsSliderWidget(
        suppressLabel: true,
        initialValue: userSettings.defaultFreeSlots,
        onChanged: (value) {
          userSettings.defaultFreeSlots = value;
        });
  }

  buildCharacterOrdering(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4),
        child: IntrinsicHeight(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildCharacterOrderItem(
                context,
                Text(
                  "Last played".translate(context),
                  textAlign: TextAlign.center,
                ),
                CharacterSortParameterType.LastPlayed),
            Container(
              width: 4,
            ),
            buildCharacterOrderItem(
                context,
                Text(
                  "First created".translate(context),
                  textAlign: TextAlign.center,
                ),
                CharacterSortParameterType.FirstCreated),
            Container(
              width: 4,
            ),
            buildCharacterOrderItem(
                context,
                Text(
                  "Last created".translate(context),
                  textAlign: TextAlign.center,
                ),
                CharacterSortParameterType.LastCreated),
          ],
        )));
  }

  buildCharacterOrderItem(BuildContext context, Widget label, CharacterSortParameterType type) {
    var selected = type == userSettings.characterOrdering.type;
    return Expanded(
      child: Material(
        color: selected ? Colors.lightBlue : Colors.blueGrey,
        child: InkWell(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            alignment: Alignment.center,
            child: label,
          ),
          onTap: () {
            userSettings.characterOrdering.type = type;
            userSettings.characterOrdering = userSettings.characterOrdering;
            setState(() {});
          },
        ),
      ),
    );
  }

  buildItemOrderList(BuildContext context) {
    return SizedBox(
        height: (itemOrdering.length + 1) * 48.0,
        child: ReorderableList(
          itemCount: itemOrdering.length,
          itemBuilder: (context, index) {
            final item = itemOrdering[index];
            return buildSortItem(context, item, index, onSave: () {
              userSettings.itemOrdering = itemOrdering;
            });
          },
          itemExtent: 48,
          onReorder: (oldIndex, newIndex) {
            final removed = itemOrdering.removeAt(oldIndex);
            itemOrdering.insert(newIndex, removed);
            userSettings.itemOrdering = itemOrdering;
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ));
  }

  Widget buildHandle(BuildContext context, int index) {
    return ReorderableDragStartListener(
        index: index,
        child: AspectRatio(aspectRatio: 1, child: Container(color: Colors.transparent, child: const Icon(Icons.menu))));
  }

  buildPursuitOrderList(BuildContext context) {
    return SizedBox(
        height: (pursuitOrdering.length + 1) * 48.0,
        child: ReorderableList(
          itemCount: pursuitOrdering.length,
          itemExtent: 48,
          onReorder: (oldIndex, newIndex) {
            var removed = pursuitOrdering.removeAt(oldIndex);
            pursuitOrdering.insert(newIndex, removed);
            userSettings.pursuitOrdering = pursuitOrdering;
          },
          itemBuilder: (context, index) {
            final item = pursuitOrdering[index];
            return buildSortItem(context, item, index, onSave: () {
              userSettings.pursuitOrdering = pursuitOrdering;
            });
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ));
  }

  Widget buildPriorityTags(BuildContext context) {
    final tags = _state.priorityTags;
    return Container(padding: const EdgeInsets.all(8));

    ///TODO: redo this
    // child: Wrap(
    //   crossAxisAlignment: WrapCrossAlignment.start,
    //   runSpacing: 4,
    //   spacing: 4,
    //   children: tags
    //       .map((t) => ItemTagWidget.fromNoteTag(
    //             context,
    //             t,
    //             onClick: () {
    //               userSettings.removePriorityTag(t);
    //               setState(() {});
    //             },
    //           ))
    //       .followedBy([
    //     ItemTagWidget.fromNoteTag(context, ItemNotesTag(icon: null, name: "Add Tag", backgroundColorHex: "#03A9f4"),
    //         padding: 4,
    //         trailing: const CenterIconWorkaround(FontAwesomeIcons.plusCircle, size: 18),
    //         onClick: () => openAddTagDialog(context)),
    //   ]).toList(),
    // ));
  }

  void openAddTagDialog(BuildContext context) async {
    final tag = await Navigator.of(context).push(SelectTagDialogRoute(context));
    if (tag != null) {
      userSettings.addPriorityTag(tag);
    }
    setState(() {});
  }

  Widget buildSortItem(BuildContext context, ItemSortParameter parameter, int index, {@required Function onSave}) {
    return Material(
        key: Key("param_${parameter.type}"),
        child: Container(
            color: parameter.active
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.secondaryContainer,
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              buildHandle(context, index),
              Container(width: 8),
              Expanded(child: buildSortLabel(parameter)),
              buildDirectionButton(parameter, SorterDirection.Ascending, onSave: onSave),
              Container(width: 4),
              buildDirectionButton(parameter, SorterDirection.Descending, onSave: onSave),
              Container(width: 8),
              Container(
                  padding: const EdgeInsets.all(8),
                  child: Switch(
                    onChanged: (value) {
                      parameter.active = value;
                      onSave();
                      setState(() {});
                    },
                    value: parameter.active,
                  ))
            ])));
  }

  Widget buildDirectionButton(ItemSortParameter parameter, SorterDirection direction, {@required Function onSave}) {
    var selected = parameter.direction == direction;
    if (!parameter.active) return Container();
    return SizedBox(
      width: 20,
      height: 20,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: selected
                ? Theme.of(context).toggleButtonsTheme.selectedColor
                : Theme.of(context).toggleButtonsTheme.color,
            padding: const EdgeInsets.all(0),
          ),
          child: Icon(
              direction == SorterDirection.Ascending ? FontAwesomeIcons.chevronUp : FontAwesomeIcons.chevronDown,
              size: 14),
          onPressed: () {
            parameter.direction = direction;
            setState(() {});
            onSave();
          }),
    );
  }

  Widget buildSortLabel(ItemSortParameter parameter) {
    return Text(parameter.type.getName(context).toUpperCase());
  }
}
