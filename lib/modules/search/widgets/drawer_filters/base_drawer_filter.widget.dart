import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/search/blocs/filter_options/base_filter_values_options.dart';
import 'package:little_light/modules/search/blocs/search_filter.bloc.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';
import 'package:provider/provider.dart';
import 'base_filter.widget.dart';

const _animationDuration = Duration(milliseconds: 300);

abstract class BaseDrawerFilterWidget<T extends BaseFilterOptions> extends BaseFilterWidget<T> {
  @override
  Widget buildWithData(BuildContext context, T data) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer2,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          buildHeader(context, data),
          buildOptionsContainer(context, data),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context, T data) {
    return AnimatedContainer(
      duration: _animationDuration,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: data.enabled ? context.theme.secondarySurfaceLayers.layer1 : context.theme.surfaceLayers.layer2,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DefaultTextStyle(child: buildTitle(context), style: context.textTheme.button),
          LLSwitch.callback(data.enabled, (value) => updateEnabled(context, value), size: LLSwitchSize.large)
        ],
      ),
    );
  }

  Widget buildOptionsContainer(BuildContext context, T data) {
    return ClipRect(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: AnimatedAlign(
          duration: _animationDuration,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.all(4),
            child: buildOptions(context, data),
          ),
          heightFactor: data.enabled ? 1 : 0,
        ));
  }

  Widget buildTitle(BuildContext context);
  Widget buildOptions(BuildContext context, T data);
}

extension BaseSetFilterWidget<Y, T extends BaseFilterOptions<Set<Y>>> on BaseFilterWidget<T> {
  void updateOption(BuildContext context, T data, Y option, bool forceAdd) {
    context.read<SearchFilterBloc>().changeSetValue(data, option, forceAdd);
  }
}
