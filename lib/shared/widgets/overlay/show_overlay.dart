import 'package:flutter/material.dart';

typedef OverlayBuilder = Widget Function(
    BuildContext context, RenderBox rect, Animation animation, Animation secondaryAnimation);

OverlayEntry? showOverlay(BuildContext context, OverlayBuilder builder) {
  final renderBox = context.findRenderObject() as RenderBox;

  Navigator.of(context).push(
    RawDialogRoute(
      pageBuilder: (context, animation, secondaryAnimation) =>
          builder(context, renderBox, animation, secondaryAnimation),
    ),
  );
  return null;
}
