import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';

mixin VisibleSectionMixin<T extends StatefulWidget> on State<T> {
  String get sectionId;

  bool get visible =>
      UserSettingsService().getVisibilityForDetailsSection(sectionId);

  Widget getHeader(Widget label) {
    return SectionHeaderWidget(
      label: label,
      sectionId: sectionId,
      onChanged: () {
        print(visible);
        setState(() {});
      },
    );
  }
}

class SectionHeaderWidget extends StatefulWidget {
  final int hash;
  final Function onChanged;
  final Widget label;
  final String sectionId;
  SectionHeaderWidget({
    this.label,
    this.hash,
    this.onChanged,
    @required this.sectionId,
    Key key,
  }) : super(key: key);
  @override
  SectionHeaderWidgetState createState() => new SectionHeaderWidgetState();
}

class SectionHeaderWidgetState<T extends SectionHeaderWidget> extends State<T> {
  bool visible = true;

  @override
  void initState() {
    super.initState();
    visible = UserSettingsService()
            .getVisibilityForDetailsSection(widget.sectionId) ??
        true;
  }

  @override
  Widget build(BuildContext context) {
    return HeaderWidget(
        child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Expanded(child: widget.label), buildTrailing(context)]));
  }

  Widget buildTrailing(BuildContext context) {
    return InkWell(
        onTap: () {
          visible = !visible;
          UserSettingsService()
              .setVisibilityForDetailsSection(widget.sectionId, visible);
          setState(() {});
          widget.onChanged?.call();
        },
        child: buildTrailingIcon(context));
  }

  Widget buildTrailingIcon(BuildContext context) {
    if (visible == false) {
      return Icon(FontAwesomeIcons.eyeSlash);
    }
    return Icon(FontAwesomeIcons.eye);
  }
}
