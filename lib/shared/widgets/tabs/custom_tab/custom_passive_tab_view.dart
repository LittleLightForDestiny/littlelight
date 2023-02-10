part of 'custom_tab.dart';

typedef _PageBuilder = Widget Function(BuildContext context, int index);

class CustomTabPassiveView extends StatelessWidget {
  final Map<int, Widget> _cachedViews = {};
  final CustomTabController controller;
  final _PageBuilder pageBuilder;

  CustomTabPassiveView({
    Key? key,
    required this.controller,
    required this.pageBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: controller.animation,
        builder: (context, child) => Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Transform.translate(
                offset: Offset(-controller.position * constraints.maxWidth, 0),
                child: Row(
                  children: List.generate(
                    controller.length,
                    (index) => SizedBox(
                      height: constraints.maxHeight,
                      width: constraints.maxWidth,
                      child: buildPage(context, index),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, int index) {
    final isMoving = controller.isMoving;
    if (!isMoving) _cachedViews.clear();
    final currentMin = controller.position.floor();
    final currentMax = controller.position.ceil();
    final shouldRender = index == currentMin || index == currentMax || _cachedViews[index] != null;
    if (!shouldRender) return Container();
    final widget = _cachedViews[index] ??= pageBuilder(context, index);
    return IgnorePointer(
      ignoring: isMoving,
      child: RepaintBoundary(
        child: widget,
      ),
    );
  }
}
