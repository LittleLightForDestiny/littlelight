import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';
import 'package:little_light/modules/search/widgets/drawer_sorters/stat_available_sorter.widget.dart';
import 'package:little_light/shared/utils/extensions/item_sort_parameter_type_data.dart';
import 'package:provider/provider.dart';

class AvailableSorterWidget extends StatelessWidget {
  final ItemSortParameter parameter;

  factory AvailableSorterWidget.fromParameter(ItemSortParameter parameter) {
    final type = parameter.type;
    if (type == ItemSortParameterType.Stat) {
      return StatAvailableSorterWidget(parameter);
    }
    return AvailableSorterWidget(parameter);
  }

  const AvailableSorterWidget(
    this.parameter, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: context.theme.surfaceLayers.layer2,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () => onTap(context),
          child: Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                buildOptionButton(context, context.theme.primaryLayers.layer1, FontAwesomeIcons.plus),
                SizedBox(width: 8),
                Expanded(
                  child: DefaultTextStyle(
                    style: context.textTheme.button,
                    child: buildName(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onTap(BuildContext context) {
    context.read<SearchSorterBloc>().addSorter(this.parameter);
  }

  Widget buildName(BuildContext context) {
    return Text(parameter.type?.getName(context).toUpperCase() ?? "");
  }

  Widget buildOptionButton(BuildContext context, Color backgroundColor, IconData icon) {
    return Container(
      width: 24,
      height: 24,
      margin: EdgeInsets.only(left: 4),
      child: Material(
        borderRadius: BorderRadius.circular(4),
        color: backgroundColor,
        child: Icon(
          icon,
          size: 16,
        ),
      ),
    );
  }
}
