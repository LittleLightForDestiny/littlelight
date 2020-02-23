import 'package:bungie_api/enums/destiny_class.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/search/search_list.widget.dart';

class LoadoutSearchListWidget extends SearchListWidget {
  final String searchText;
  final int bucketType;
  final DestinyClass classType;
  final Iterable<String> idsToAvoid;
  LoadoutSearchListWidget({Key key, this.searchText, this.bucketType, this.classType, this.idsToAvoid}) : super(key: key);

  @override
  LoadoutSearchListWidgetState createState() => LoadoutSearchListWidgetState();
}

class LoadoutSearchListWidgetState
    extends SearchListWidgetState<LoadoutSearchListWidget> {
  
}
