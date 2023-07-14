import 'package:flutter/material.dart';
import 'package:little_light/modules/settings/widgets/settings_option.widget.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';

class SwitchOptionWidget extends SettingsOptionWidget {
  SwitchOptionWidget(String title, String description, {Key? key, required bool value, required BoolCallback onChanged})
      : super(
          title,
          Container(
              padding: EdgeInsets.all(4),
              child: Text(
                description,
                textAlign: TextAlign.start,
              )),
          trailing: LLSwitch.callback(value, onChanged),
        );
}
