import 'package:flutter/material.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/item_filters/text_filter.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class TextSearchFilterWidget
    extends BaseSearchFilterWidget<TextFilter> {
  final bool forceAutoFocus;
  TextSearchFilterWidget(SearchController controller, {this.forceAutoFocus:false}) : super(controller);

  @override
  _TextSearchFilterWidgetState createState() =>
      _TextSearchFilterWidgetState();
}

class _TextSearchFilterWidgetState
    extends BaseSearchFilterWidgetState<TextSearchFilterWidget, TextFilter, String> {
  TextEditingController _searchFieldController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchFieldController.text = widget.filter.value;
    _searchFieldController.addListener(updateText);
  }

  @override
  dispose(){
    _searchFieldController.removeListener(updateText);
    super.dispose();
  }

  updateText() {
    filter.value = _searchFieldController.text;
    setState(() {});
    widget.controller.update();
  }
  

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: UserSettingsService().autoOpenKeyboard || widget.forceAutoFocus,
      controller: _searchFieldController,
    );
  }
}
