import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/modules/search/blocs/filter_types/text_filter_wrapper.dart';
import 'package:little_light/modules/search/widgets/base_filter.widget.dart';
import 'package:little_light/modules/search/widgets/text_search_filter_field.widget.dart';

class TextSearchFilterWidget extends BaseFilterWidget<TextFilterWrapper> {
  TextSearchFilterWidget({Key? key}) : super();

  @override
  Widget buildWithData(BuildContext context, TextFilterWrapper? data) {
    return TextSearchFilterFieldWidget(
      onUpdate: (text) => this.update(context, TextFilterWrapper(text)),
    );
  }
}
