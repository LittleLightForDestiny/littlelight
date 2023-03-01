import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/modules/search/blocs/filter_options/text_filter_options.dart';
import 'package:little_light/modules/search/widgets/base_filter.widget.dart';
import 'package:little_light/modules/search/widgets/text_search_filter_field.widget.dart';

class TextSearchFilterWidget extends BaseFilterWidget<TextFilterOptions> {
  TextSearchFilterWidget({Key? key}) : super();

  @override
  Widget buildWithData(BuildContext context, TextFilterOptions? data) {
    return TextSearchFilterFieldWidget(
      onUpdate: (text) {
        this.update(context, TextFilterOptions(text));
      },
    );
  }
}
