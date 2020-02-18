import 'package:flutter/material.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/item_filters/text_filter.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class TextSearchFilterWidget
    extends BaseSearchFilterWidget<TextFilter> {
  TextSearchFilterWidget(SearchController controller) : super(controller);

  @override
  _TextSearchFilterWidgetState createState() =>
      _TextSearchFilterWidgetState();
}

class _TextSearchFilterWidgetState
    extends BaseSearchFilterWidgetState<TextSearchFilterWidget> {
  TextEditingController _searchFieldController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchFieldController.text = widget.filter.value;
    _searchFieldController.addListener(updateText);
  }

  @override
  dispose(){
    super.dispose();
    _searchFieldController.removeListener(updateText);
  }

  updateText() {
    filter.value = _searchFieldController.text;
    setState(() {});
    widget.controller.update();
  }
  

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: UserSettingsService().autoOpenKeyboard,
      controller: _searchFieldController,
    );
  }
}
