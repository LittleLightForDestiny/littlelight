import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/ammo_type_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/class_type_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/damage_type_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/energy_level_constraints_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/energy_type_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/item_bucket_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/item_subtype_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/power_level_constraints_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/seasonal_slot_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/tier_type_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/total_stats_constraints_filter.widget.dart';
import 'package:little_light/widgets/search/search_filters/wishlist_tag_filter.widget.dart';

class SearchFilterMenu extends StatefulWidget {
  final SearchController controller;

  SearchFilterMenu({this.controller, Key key}):super(key:key);

  @override
  _SearchFilterMenuState createState() => _SearchFilterMenuState();
}

class _SearchFilterMenuState extends State<SearchFilterMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        AppBar(
          title: TranslatedTextWidget("Filters"),
          automaticallyImplyLeading: false,
          actions: <Widget>[Container()],
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Expanded(child: ListView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          children: buildFilters(context)))
      ],
    ));
  }

  List<Widget> buildFilters(BuildContext context){
    return [
      PowerLevelConstraintsWidget(widget.controller),
      EnergyLevelConstraintsWidget(widget.controller),
      DamageTypeFilterWidget(widget.controller),
      EnergyTypeFilterWidget(widget.controller),
      SeasonalSlotFilterWidget(widget.controller),
      AmmoTypeFilterWidget(widget.controller),
      ClassTypeFilterWidget(widget.controller),
      TierTypeFilterWidget(widget.controller),
      ItemBucketFilterWidget(widget.controller),
      TotalStatsConstraintsWidget(widget.controller),
      ItemSubTypeFilterWidget(widget.controller),
      WishlistTagsFilterWidget(widget.controller),
      ];
  }
}
