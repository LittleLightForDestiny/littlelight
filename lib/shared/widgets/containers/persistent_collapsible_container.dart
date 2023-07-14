import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:provider/provider.dart';

const _animationDuration = Duration(milliseconds: 300);
const _defaultToggleButtonSize = 20.0;
const _defaultHeaderSpacing = 8.0;

class PersistentCollapsibleContainer extends StatelessWidget {
  final Widget content;
  final Widget title;
  final String persistenceID;
  double get headerSpacing => _defaultHeaderSpacing;
  double get toggleButtonSize => _defaultToggleButtonSize;

  const PersistentCollapsibleContainer({
    required this.title,
    required this.content,
    required this.persistenceID,
  });
  @override
  Widget build(BuildContext context) {
    final visible = context.watch<UserSettingsBloc>().getSectionVisibleState(persistenceID);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildHeader(context, visible),
        buildContent(context, visible),
      ],
    );
  }

  Widget buildHeader(BuildContext context, bool visible) {
    return HeaderWidget(
        child: Row(children: [
      Expanded(child: title),
      buildToggleButton(context, visible),
    ]));
  }

  Widget buildToggleButton(BuildContext context, bool visible) {
    final icon = visible ? FontAwesomeIcons.solidSquareMinus : FontAwesomeIcons.solidSquarePlus;
    return Stack(
      children: [
        Icon(
          icon,
          size: toggleButtonSize,
        ),
        Positioned.fill(
          child: InkWell(
            onTap: () => context.read<UserSettingsBloc>().setSectionVisibleState(persistenceID, !visible),
            child: Material(
              color: Colors.transparent,
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildContent(BuildContext context, bool opened) {
    return ClipRect(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: AnimatedAlign(
          duration: _animationDuration,
          alignment: Alignment.center,
          child: Container(
            constraints: BoxConstraints(minWidth: double.infinity),
            padding: EdgeInsets.only(top: headerSpacing),
            child: content,
          ),
          heightFactor: opened ? 1 : 0,
        ));
  }
}
