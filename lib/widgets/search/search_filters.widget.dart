import 'package:flutter/material.dart';

enum FilterTypes{
  powerLevel,
  bucketType,
  tierType,
  itemSubType,
  classType,
}

class SearchFiltersWidget extends StatefulWidget {
  const SearchFiltersWidget({Key key}) : super(key: key);
  @override
  SearchFiltersWidgetState createState() => new SearchFiltersWidgetState();
}

class SearchFiltersWidgetState extends State<SearchFiltersWidget> {

  @override
  initState() {
    super.initState();
  }

  loadItems() async {
    
  }

  Widget build(BuildContext context) {
    return Container(width:280, color:Colors.blueGrey.shade900);
  }
}
