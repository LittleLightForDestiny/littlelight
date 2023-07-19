import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

abstract class BaseOverlayWidget extends StatelessWidget {
  final bool canDismissOnBackground;
  final GlobalKey buttonKey;
  final Animation? animation;

  const BaseOverlayWidget({
    Key? key,
    required this.buttonKey,
    this.canDismissOnBackground = true,
    Animation? this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final sourceRenderBox = buttonKey.currentContext?.findRenderObject();
      if (!(sourceRenderBox is RenderBox)) return Container();
      final rect = Rect.fromPoints(
        sourceRenderBox.localToGlobal(sourceRenderBox.size.topLeft(Offset.zero)),
        sourceRenderBox.localToGlobal(sourceRenderBox.size.bottomRight(Offset.zero)),
      );
      final top = rect.top;
      final left = rect.left;
      final bottom = constraints.maxHeight - rect.bottom;
      final right = constraints.maxWidth - rect.right;
      final fullsizeMaskRect = Rect.fromLTRB(
          -constraints.maxWidth * 2, -constraints.maxHeight, constraints.maxWidth * 2, constraints.maxHeight * 2);
      final animation = this.animation;
      if (animation == null) return Container();
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) =>
            ClipOval(clipper: _OvalClipper(Rect.lerp(rect, fullsizeMaskRect, animation.value)!), child: child),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              buildDismissBackground(context),
              Positioned.fill(
                child: buildOverlay(
                  context,
                  sourceTop: top,
                  sourceLeft: left,
                  sourceBottom: bottom,
                  sourceRight: right,
                  constraints: constraints,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildDismissBackground(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => hide(context),
        child: Container(
          color: context.theme.surfaceLayers.layer0.withOpacity(.6),
        ),
      ),
    );
  }

  void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  Widget buildOverlay(
    BuildContext context, {
    required double sourceTop,
    required double sourceLeft,
    required double sourceBottom,
    required double sourceRight,
    required BoxConstraints constraints,
  });
}

class _OvalClipper extends CustomClipper<Rect> {
  final Rect rect;

  _OvalClipper(this.rect);

  @override
  Rect getClip(Size size) {
    return rect;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}
