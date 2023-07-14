import 'base_filter_values_options.dart';

class TextFilterOptions extends BaseFilterOptions<String?> {
  TextFilterOptions([String? value]) : super(value ?? "", availableValues: "");

  @override
  bool get available => true;

  @override
  bool get enabled => true;
}
