
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/sockets/plug_grid_view.dart';

class PaginatedPlugGridView extends PlugGridView {
  const PaginatedPlugGridView.withItemsPerRow(
    List<int> plugHashes, {
    required ItemBuilder itemBuilder,
    required int itemsPerRow,
    double gridSpacing = 8,
    int maxRows = 3,
  }) : super.withItemsPerRow(
          plugHashes,
          itemBuilder: itemBuilder,
          itemsPerRow: itemsPerRow,
          gridSpacing: gridSpacing,
          maxRows: maxRows,
        );

  const PaginatedPlugGridView.withExpectedItemSize(
    List<int?> plugHashes, {
    required ItemBuilder itemBuilder,
    required double expectedItemSize,
    double gridSpacing = 8,
    int maxRows = 3,
  }) : super.withExpectedItemSize(
          plugHashes,
          itemBuilder: itemBuilder,
          expectedItemSize: expectedItemSize,
          gridSpacing: gridSpacing,
          maxRows: maxRows,
        );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var specs = getSpecs(constraints.maxWidth);
      if (specs.pageCount <= 1) {
        return buildScrollableGrid(context, specs);
      }
      specs = getSpecs(constraints.maxWidth - 32);
      return DefaultTabController(
          length: specs.pageCount,
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
            border: Border.all(color: LittleLightTheme.of(context).onSurfaceLayers.layer1),
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
