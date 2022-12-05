import 'package:flutter/material.dart';

typedef OverlayBuilder = Widget Function(BuildContext context, RenderBox rect, void Function() onClose);

OverlayEntry? showOverlay(BuildContext context, OverlayBuilder builder) {
  final renderBox = context.findRenderObject() as RenderBox;
  final overlay = Overlay.of(context);
  if (overlay == null) return null;
  OverlayEntry? overlayEntry;
  final onClose = () => overlayEntry?.remove();
  overlayEntry = OverlayEntry(
    builder: (context) {
      return builder(context, renderBox, onClose);
    },
  );

  overlay.insert(overlayEntry);
  return overlayEntry;
}
