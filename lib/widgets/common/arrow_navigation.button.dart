import 'package:flutter/material.dart';

class ArrowNavigationButton extends StatelessWidget {
  final bool enabled;
  final IconData icon;

  ArrowNavigationButton({Key key, this.enabled = true, @required this.icon})
      : super(key: key);

  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.5,
        duration: Duration(milliseconds: 500),
        child: Material(
            color:
                Theme.of(context).primaryTextTheme.button.color.withOpacity(.3),
            child: InkWell(
                child: Icon(
              icon,
              color: Theme.of(context).primaryTextTheme.button.color,
            ))));
  }
}
