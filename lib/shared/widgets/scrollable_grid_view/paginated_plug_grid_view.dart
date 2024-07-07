import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/scrollable_grid_view/scrollable_grid_view.base.dart';

class PaginatedScrollableGridView<T> extends ScrollableGridViewBase<T> {
  final int initialFocus;

  const PaginatedScrollableGridView.withExpectedItemSize(
    List<T> records, {
    Key? super.key,
    super.maxRows = 3,
    super.gridSpacing = 8,
    required super.itemBuilder,
    required super.expectedCrossAxisSize,
    this.initialFocus = 0,
    double? super.itemMainAxisExtent,
  }) : super.withExpectedItemSize(records);

  const PaginatedScrollableGridView.withItemsPerRow(
    List<T> records, {
    Key? key,
    int maxRows = 3,
    required ScrollableGridViewItemBuilder<T> itemBuilder,
    required int itemsPerRow,
    double gridSpacing = 8,
    double? itemMainAxisExtent,
    this.initialFocus = 0,
  }) : super.withItemsPerRow(
          records,
          key: key,
          itemBuilder: itemBuilder,
          itemsPerRow: itemsPerRow,
          gridSpacing: gridSpacing,
          maxRows: maxRows,
          itemMainAxisExtent: itemMainAxisExtent,
        );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var specs = getSpecs(constraints.maxWidth);
      if (specs.pageCount <= 1) {
        return buildScrollableGrid(context, specs);
      }
      specs = getSpecs(constraints.maxWidth - 32);
      final initialIndex = (initialFocus / specs.itemsPerPage).floor();
      return DefaultTabController(
          length: specs.pageCount,
          initialIndex: initialIndex.clamp(0, specs.pageCount),
          child: SizedBox(
            height: specs.tabHeight,
            child: Row(children: [
              Builder(builder: (context) => pagingButton(context, -1)),
              Expanded(child: Builder(builder: (context) => buildScrollableGrid(context, specs))),
              Builder(builder: (context) => pagingButton(context, 1)),
            ]),
          ));
    });
  }
}

Widget pagingButton(BuildContext context, [int direction = 1]) {
  final controller = DefaultTabController.of(context);
  final length = controller.length;

  return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, child) {
        final currentIndex = controller.index;
        final enabled = direction < 0 ? currentIndex > 0 : currentIndex < length - 1;
        return Container(
          constraints: const BoxConstraints.expand(width: 16),
          decoration: BoxDecoration(
            border: Border.all(color: context.theme.onSurfaceLayers.layer1),
          ),
          alignment: Alignment.center,
          child: !enabled
              ? Container(color: Colors.grey.shade300.withOpacity(.2))
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                      onTap: () {
                        controller.animateTo(currentIndex + direction);
                      },
                      child: Container(
                          constraints: const BoxConstraints.expand(),
                          child: Icon(direction > 0 ? FontAwesomeIcons.caretRight : FontAwesomeIcons.caretLeft,
                              size: 16)))),
        );
      });
}
