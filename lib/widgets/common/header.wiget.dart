import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  HeaderWidget({this.child, this.padding = const EdgeInsets.all(8)});
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: AlignmentDirectional.bottomCenter,
        padding: padding,
        decoration: BoxDecoration(
          border: BorderDirectional(bottom: BorderSide(color: Colors.white)),
          color: Colors.white.withOpacity(0.2),
        ),
        child: child);
  }
}
