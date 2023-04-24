import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

typedef BoolCallback = void Function(bool value);

enum LLSwitchSize {
  small,
  large,
}

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

class LLSwitch extends StatefulWidget {
  final ValueNotifier<bool>? controller;
  final bool? value;
  final BoolCallback? onChanged;
  final LLSwitchSize size;

  factory LLSwitch(ValueNotifier<bool> controller, {Key? key, LLSwitchSize size = LLSwitchSize.small}) => LLSwitch._(
        controller: controller,
        key: key,
        size: size,
      );
  factory LLSwitch.callback(bool value, BoolCallback onChanged, {Key? key, LLSwitchSize size = LLSwitchSize.small}) =>
      LLSwitch._(
        value: value,
        onChanged: onChanged,
        size: size,
      );

  const LLSwitch._({
    ValueNotifier<bool>? this.controller,
    Key? key,
    this.value,
    this.onChanged,
    this.size = LLSwitchSize.small,
  }) : super(key: key);

  @override
  State<LLSwitch> createState() => _LLSwitchState();
}

class _LLSwitchState extends State<LLSwitch> {
  ValueNotifier<bool>? _controller;
  ValueNotifier<bool> get controller =>
      widget.controller ?? (_controller ??= ValueNotifier<bool>(widget.value ?? false));

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      widget.onChanged?.call(controller.value);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LLSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = widget.value;
    if (value != null) {
      _controller?.value = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedSwitch(
      controller: controller,
      width: widget.size.dimensions.width,
      height: widget.size.dimensions.height,
      activeColor: context.theme.primaryLayers,
    );
  }
}
