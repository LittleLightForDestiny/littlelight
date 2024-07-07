import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

class HeaderWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Alignment alignment;
  const HeaderWidget(
      {required this.child, this.padding = const EdgeInsets.all(8), this.alignment = Alignment.centerLeft});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
          border: BorderDirectional(bottom: BorderSide(color: context.theme.onSurfaceLayers.layer0)),
          gradient: LinearGradient(
              colors: const [Color.fromRGBO(255, 255, 255, 0), Color.fromRGBO(255, 255, 255, .1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: DefaultTextStyle(
          textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold), child: child),
    );
  }
}
