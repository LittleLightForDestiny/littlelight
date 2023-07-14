import 'package:little_light/models/item_sort_parameter.dart';

final searchSorterOptions = [
  ItemSortParameter(type: ItemSortParameterType.PowerLevel, direction: SorterDirection.Descending),
  ItemSortParameter(type: ItemSortParameterType.TierType, direction: SorterDirection.Descending),
  ItemSortParameter(type: ItemSortParameterType.Name),
  ItemSortParameter(type: ItemSortParameterType.StatTotal, direction: SorterDirection.Descending),
  ItemSortParameter(type: ItemSortParameterType.Stat),
  ItemSortParameter(type: ItemSortParameterType.MasterworkStatus, direction: SorterDirection.Descending),
  ItemSortParameter(type: ItemSortParameterType.ItemOwner),
  ItemSortParameter(type: ItemSortParameterType.SubType),
  ItemSortParameter(type: ItemSortParameterType.ClassType),
  ItemSortParameter(type: ItemSortParameterType.DamageType),
  ItemSortParameter(type: ItemSortParameterType.AmmoType),
  ItemSortParameter(type: ItemSortParameterType.BucketHash),
  ItemSortParameter(type: ItemSortParameterType.Quantity),
];
