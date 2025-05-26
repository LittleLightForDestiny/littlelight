import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

typedef BoolCallback = void Function(bool value);

enum LLSwitchSize { small, large }

extension on LLSwitchSize {
  Size get dimensions {
    switch (this) {
      case LLSwitchSize.small:
        return Size(28, 16);
      case LLSwitchSize.large:
        return Size(36, 20);
    }
  }
}

class LLSwitch extends StatelessWidget {
  final bool? value;
  final BoolCallback? onChanged;
  final LLSwitchSize size;
  factory LLSwitch.callback(bool value, BoolCallback onChanged, {Key? key, LLSwitchSize size = LLSwitchSize.small}) =>
      LLSwitch._(value: value, onChanged: onChanged, size: size);

  const LLSwitch._({Key? key, this.value, this.onChanged, this.size = LLSwitchSize.small}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      value: value ?? false,
      onToggle: (value) {
        onChanged?.call(value);
      },
      valueFontSize: 0,
      padding: 2,
      width: size.dimensions.width,
      height: size.dimensions.height,
      toggleSize: size.dimensions.height - 4,
      activeColor: context.theme.primaryLayers,
    );
  }
}
