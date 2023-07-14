import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_options/text_filter_options.dart';
import 'package:little_light/modules/search/widgets/drawer_filters/base_filter.widget.dart';
import 'package:little_light/modules/search/widgets/text_search_filter_field.widget.dart';
import 'package:provider/provider.dart';

class TextSearchFilterWidget extends BaseFilterWidget<TextFilterOptions> {
  TextSearchFilterWidget({Key? key}) : super();

  @override
  Widget buildWithData(BuildContext context, TextFilterOptions? data) {
    return TextSearchFilterFieldWidget(
      onUpdate: (text) {
        this.update(context, TextFilterOptions(text));
      },
      forceAutoFocus: context.read<UserSettingsBloc>().autoOpenKeyboard,
    );
  }
}
