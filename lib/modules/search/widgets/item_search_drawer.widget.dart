import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/search/widgets/filters_list.widget.dart';
import 'package:little_light/modules/search/widgets/sorters_list.widget.dart';

class ItemSearchDrawerWidget extends StatelessWidget {
  const ItemSearchDrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Drawer(
      elevation: 0,
      backgroundColor: context.theme.surfaceLayers.layer1,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: context.theme.secondarySurfaceLayers.layer0,
              height: kToolbarHeight + mq.viewPadding.top,
              child: TabBar(
                tabs: [
                  Container(
                    margin: EdgeInsets.only(top: mq.viewPadding.top),
                    child: Text("Filters".translate(context)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: mq.viewPadding.top),
                    child: Text("Sort".translate(context)),
                  ),
                ],
              ),
            ),
            Expanded(
                child: TabBarView(
              children: [
                FiltersListWidget(padding: EdgeInsets.only(bottom: mq.viewPadding.bottom)),
                SortersListWidget(padding: EdgeInsets.only(bottom: mq.viewPadding.bottom)),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
