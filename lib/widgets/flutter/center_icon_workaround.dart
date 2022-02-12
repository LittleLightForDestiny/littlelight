//@dart=2.12
import 'package:flutter/material.dart';

class CenterIconWorkaround extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  CenterIconWorkaround(this.icon, {Key? key, this.size, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Text(String.fromCharCode(icon.codePoint),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: icon.fontFamily,
                package: icon.fontPackage,
                height: 1,
                fontSize: size ?? Theme.of(context).iconTheme.size,
                color: color ?? Theme.of(context).iconTheme.color)));
  }
}
