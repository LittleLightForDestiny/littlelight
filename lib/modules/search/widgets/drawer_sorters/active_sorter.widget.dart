import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';
import 'package:little_light/modules/search/widgets/drawer_sorters/stat_active_sorter.widget.dart';
import 'package:little_light/shared/utils/extensions/item_sort_parameter_type_data.dart';
import 'package:provider/provider.dart';

class ActiveSorterWidget extends StatelessWidget {
  final int index;
  final ItemSortParameter parameter;

  factory ActiveSorterWidget.fromParameter(ItemSortParameter parameter, int index) {
    final type = parameter.type;
    if (type == ItemSortParameterType.Stat) {
      return StatActiveSorterWidget(parameter, index);
    }
    return ActiveSorterWidget(parameter, index);
  }

  const ActiveSorterWidget(
    this.parameter,
    this.index, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer2,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(index: index, child: Icon(FontAwesomeIcons.bars)),
          SizedBox(width: 8),
          Expanded(
            child: DefaultTextStyle(
              style: context.textTheme.button,
              child: buildName(context),
            ),
          ),
          SizedBox(width: 8),
          buildOptions(context),
        ],
      ),
    );
  }

  Widget buildName(BuildContext context) {
    return Text(parameter.type?.getName(context).toUpperCase() ?? "");
  }

  Widget buildOptions(BuildContext context) {
    final enabledColor = context.theme.primaryLayers.layer1;
    final disabledColor =
        Color.lerp(context.theme.surfaceLayers.layer1, enabledColor, .5) ?? context.theme.surfaceLayers.layer1;
    final hasDirectionOptions = [SorterDirection.Ascending, SorterDirection.Descending].contains(parameter.direction);
    final isAscending = parameter.direction == SorterDirection.Ascending;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDirectionOptions)
          buildOptionButton(
            context,
            isAscending ? enabledColor : disabledColor,
            FontAwesomeIcons.chevronUp,
            !isAscending
                ? () => context.read<SearchSorterBloc>().updateDirection(parameter, SorterDirection.Ascending)
                : null,
          ),
        if (hasDirectionOptions)
          buildOptionButton(
            context,
            !isAscending ? enabledColor : disabledColor,
            FontAwesomeIcons.chevronDown,
            isAscending
                ? () => context.read<SearchSorterBloc>().updateDirection(parameter, SorterDirection.Descending)
                : null,
          ),
        buildOptionButton(
          context,
          context.theme.errorLayers.layer2,
          FontAwesomeIcons.xmark,
          () => context.read<SearchSorterBloc>().removeSorter(parameter),
        ),
      ],
    );
  }

  Widget buildOptionButton(BuildContext context, Color backgroundColor, IconData icon, VoidCallback? onTap) {
    return Container(
      width: 24,
      height: 24,
      margin: EdgeInsets.only(left: 4),
      child: Material(
        borderRadius: BorderRadius.circular(4),
        color: backgroundColor,
        child: InkWell(
          child: Icon(
            icon,
            size: 16,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
