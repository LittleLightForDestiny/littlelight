import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/shared/utils/extensions/item_sort_parameter_type_data.dart';

typedef OnChangeSorterDirection = void Function(SorterDirection);
typedef OnActiveToggle = void Function(bool);

class ItemOrderParameterWidget extends StatelessWidget {
  final ItemSortParameter parameter;
  final int index;
  final OnActiveToggle? onToggle;
  final OnChangeSorterDirection? onChangeDirection;

  const ItemOrderParameterWidget(
    this.parameter,
    this.index, {
    Key? key,
    this.onChangeDirection,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: parameter.active ? 1 : .7,
      child: Container(
        margin: EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.all(4),
        height: 36,
        color: context.theme.surfaceLayers.layer1,
        child: Material(
          color: Colors.transparent,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            buildHandle(context, index),
            Container(width: 8),
            Expanded(
              child: Text(
                parameter.type?.getName(context).toUpperCase() ?? "",
                style: context.textTheme.highlight,
              ),
            ),
            buildDirectionButton(context),
            Container(width: 8),
            Container(
                padding: const EdgeInsets.all(8),
                child: Switch(
                  onChanged: onToggle,
                  value: parameter.active,
                ))
          ]),
        ),
      ),
    );
  }

  Widget buildHandle(BuildContext context, int index) {
    return ReorderableDragStartListener(
      index: index,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          alignment: Alignment.center,
          color: Colors.transparent,
          child: const Icon(
            Icons.menu,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget buildDirectionButton(BuildContext context) {
    if (!parameter.active) return Container();
    return SizedBox(
      width: 20,
      height: 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          backgroundColor: context.theme.primaryLayers,
          foregroundColor: context.theme.onSurfaceLayers,
        ),
        child: Icon(
            parameter.direction == SorterDirection.Ascending
                ? FontAwesomeIcons.chevronUp
                : FontAwesomeIcons.chevronDown,
            size: 14),
        onPressed: () {
          final direction = [SorterDirection.Ascending, SorterDirection.Descending]
              .firstWhere((element) => element != parameter.direction);
          onChangeDirection?.call(direction);
        },
      ),
    );
  }
}
