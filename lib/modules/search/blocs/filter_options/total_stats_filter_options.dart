import 'base_filter_values_options.dart';

class TotalStatsConstraints {
  int max;
  int min;
  TotalStatsConstraints(this.min, this.max);
}

class TotalStatsFilterOptions extends BaseFilterOptions<TotalStatsConstraints> {
  TotalStatsFilterOptions(int min, int max)
      : super(TotalStatsConstraints(min, max),
            availableValues: TotalStatsConstraints(min, max));
}
