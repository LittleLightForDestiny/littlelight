import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Alignment alignment;
  HeaderWidget({this.child, this.padding = const EdgeInsets.all(8), this.alignment = Alignment.centerLeft});
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: alignment,
        padding: padding,
        decoration: BoxDecoration(
          border: BorderDirectional(bottom: BorderSide(color: Theme.of(context).colorScheme.onSurface)),
          gradient: LinearGradient(colors: [Color.fromRGBO(255, 255, 255, 0), Color.fromRGBO(255, 255, 255, .1)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
        ),
        child: 
        DefaultTextStyle(
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold),
          child: child),);
  }
}
