import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final Widget child;

  HeaderWidget({this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: AlignmentDirectional.bottomCenter,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: BorderDirectional(bottom: BorderSide(color: Colors.white)),
          color: Colors.white.withOpacity(0.2),
        ),
        child: child);
  }
}
