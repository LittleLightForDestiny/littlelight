import 'package:flutter/material.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/search/search_filters.widget.dart';
import 'package:little_light/widgets/search/search_list.widget.dart';

class LoadoutSearchListWidget extends SearchListWidget {
  final String searchText;
  final int bucketType;
  LoadoutSearchListWidget({Key key, this.searchText, this.bucketType}) : super(key: key);

  @override
  LoadoutSearchListWidgetState createState() => LoadoutSearchListWidgetState();
}

class LoadoutSearchListWidgetState
    extends SearchListWidgetState<LoadoutSearchListWidget> {
  @override
  String get search => widget.searchText;
  
  @override
  FilterItem get powerLevelFilter => null;
  
  @override
  FilterItem get damageTypeFilter => null;
  
  @override
  FilterItem get tierTypeFilter => null;
  
  @override
  FilterItem get bucketTypeFilter => FilterItem([widget.bucketType], [widget.bucketType]);
  
  @override
  FilterItem get subtypeFilter => null;
  
  @override
  FilterItem get typeFilter => null;
  
  @override
  FilterItem get ammoTypeFilter => null;
  
  @override
  FilterItem get classTypeFilter => null;

  @override
  List<int> get itemTypes => null;
  
  @override
  List<int> get excludeItemTypes => null;

  @override
  List<SortParameter> get sortOrder => [SortParameter(SortParameterType.power, -1)];
}
