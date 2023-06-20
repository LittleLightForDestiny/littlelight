import 'package:bungie_api/src/enums/destiny_class.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/search/blocs/search_filter.bloc.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';
import 'package:little_light/modules/search/pages/item_search/item_search.bloc.dart';
import 'package:little_light/modules/search/pages/item_search/item_search.view.dart';
import 'package:little_light/modules/search/pages/quick_transfer/quick_transfer.bloc.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:little_light/shared/utils/helpers/bucket_type_groups.dart';
import 'package:provider/provider.dart';

class ItemSearchPage extends StatelessWidget {
  final DestinyClass? classType;
  final EquipmentBucketGroup? currentBucketGroup;

  const ItemSearchPage(
    this.currentBucketGroup,
    this.classType, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SearchFilterBloc(context)),
        ChangeNotifierProvider<SearchSorterBloc>(create: (context) {
          final activeSorters =
              context.read<UserSettingsBloc>().itemOrdering?.where((s) => s.active).toList() ?? <ItemSortParameter>[];
          return SearchSorterBloc(context, activeSorters: activeSorters);
        }),
        ChangeNotifierProvider(
          create: (context) {
            final currentBucketGroup = this.currentBucketGroup;
            final groups = {if (currentBucketGroup != null) currentBucketGroup};
            return ItemSearchBloc(context, bucketGroups: groups);
          },
        ),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<ItemSearchBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => item is InventoryItemInfo ? bloc.onItemTap(item) : null,
            onHold: (item) => item is InventoryItemInfo ? bloc.onItemHold(item) : null,
          );
        }),
      ],
      builder: (context, _) => ItemSearchView(
        context.read<ItemSearchBloc>(),
        context.watch<ItemSearchBloc>(),
      ),
    );
  }
}
