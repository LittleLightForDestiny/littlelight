part of 'custom_tab.dart';

class CustomTabGestureDetector extends StatelessWidget {
  final CustomTabController controller;
  const CustomTabGestureDetector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              controller._dragStart();
            },
            onPanUpdate: (details) {
              final offset = -details.delta / constraints.maxWidth;
              final shouldConsider = offset.dx.abs() > offset.dy.abs();
              if (!shouldConsider) return;
              controller._dragBy(offset.dx);
            },
            onPanEnd: (details) {
              controller._dragStop();
            },
            onPanCancel: () {
              controller._dragStop();
            },
          )),
    );
  }
}
