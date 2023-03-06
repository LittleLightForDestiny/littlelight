import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';

mixin VisibleSectionMixin<T extends StatefulWidget> on State<T> {
  String get sectionId;

  bool get visible => getInjectedUserSettings().getVisibilityForDetailsSection(sectionId);

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
  final Function? onChanged;
  final Widget label;
  final String sectionId;
  const SectionHeaderWidget({
    required this.label,
    this.onChanged,
    required this.sectionId,
    Key? key,
  }) : super(key: key);
  @override
  SectionHeaderWidgetState createState() => SectionHeaderWidgetState();
}

class SectionHeaderWidgetState<T extends SectionHeaderWidget> extends State<T> with UserSettingsConsumer {
  bool visible = true;

  @override
  void initState() {
    super.initState();
    visible = userSettings.getVisibilityForDetailsSection(widget.sectionId);
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
          userSettings.setVisibilityForDetailsSection(widget.sectionId, visible);
          setState(() {});
          widget.onChanged?.call();
        },
        child: buildTrailingIcon(context));
  }

  Widget buildTrailingIcon(BuildContext context) {
    if (visible == false) {
      return const Icon(FontAwesomeIcons.eyeSlash);
    }
    return const Icon(FontAwesomeIcons.eye);
  }
}
