import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/animations/ping_pong_animation.dart';
import 'package:little_light/shared/widgets/animations/single_run_animation.dart';

abstract class BaseOverlayWidget extends StatelessWidget {
  final bool canDismissOnBackground;
  final RenderBox sourceRenderBox;
  final void Function() onClose;

  const BaseOverlayWidget({
    Key? key,
    required this.sourceRenderBox,
    required this.onClose,
    this.canDismissOnBackground = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
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
      return SingleRunAnimationBuilder(
        (controller) => AnimatedBuilder(
            animation: controller,
            builder: (context, child) =>
                ClipOval(child: child, clipper: _OvalClipper(Rect.lerp(rect, fullsizeMaskRect, controller.value)!)),
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
            )),
        duration: Duration(milliseconds: 700),
      );
    });
  }

  Widget buildDismissBackground(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => hide(context),
        child: Container(
          color: context.theme?.surfaceLayers.layer0.withOpacity(.6),
        ),
      ),
    );
  }

  void hide(BuildContext context) {
    onClose();
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
