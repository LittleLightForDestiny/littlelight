import 'package:flutter/material.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/containers/menu_box_title.dart';

class SettingsOptionWidget extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? trailing;
  final Color? backgroundColor;

  const SettingsOptionWidget(this.title, this.content, {Key? key, this.trailing, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuBox(
      backgroundColor: getBackgroundColor(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MenuBoxTitle(
          title,
          trailing: buildTrailing(context),
        ),
        Container(padding: EdgeInsets.all(4), child: content),
      ]),
    );
  }

  Widget? buildTrailing(BuildContext context) {
    return trailing;
  }

  Color? getBackgroundColor(BuildContext context) {
    return backgroundColor ?? null;
  }
}
