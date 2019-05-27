import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_investment_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_details/item_stats.widget.dart';

class PerkListItem extends StatefulWidget {
  final DestinyInventoryItemDefinition definition;
  final bool alwaysOpen;
  final bool curated;
  final bool equipped;
  final bool selected;

  const PerkListItem({Key key, this.definition, this.alwaysOpen = false, this.curated = false, this.equipped = false, this.selected = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PerkListItemState();
  }
}

class PerkListItemState extends State<PerkListItem>
    with TickerProviderStateMixin {
  DestinyInventoryItemDefinition get definition => widget.definition;
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: widget.equipped ? Colors.lightBlue.shade600 : Colors.blueGrey.shade700,
            borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    child: QueuedNetworkImage(
                      imageUrl: BungieApiService.url(
                          definition?.displayProperties?.icon),
                    ),
                  ),
                  Container(
                    width: 8,
                  ),
                  Text(
                    definition?.displayProperties?.name ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  widget.curated ? Icon(FontAwesomeIcons.crown, size: 14,) : Container(),
                  Container(width: 8,),
                  buildExpandButton(context),
                ],
              )
            ],
          ),
          AnimatedCrossFade(
              crossFadeState:
                  open  || widget.alwaysOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              alignment: Alignment.topCenter,
              duration: Duration(milliseconds: 300),
              firstChild: Container(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        definition?.displayProperties?.description ?? "",
                      )),
                      buildStats(context, definition?.investmentStats)
                ],
              )),
        ]));
  }

  buildExpandButton(BuildContext context) {
    if(widget.alwaysOpen) return Container();
    return Stack(children: [
      Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          child: Icon(
              open ? FontAwesomeIcons.minusCircle : FontAwesomeIcons.plusCircle,
              size: 18)),
      Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  open = !open;
                  setState(() {});
                },
              )))
    ]);
  }

  buildStats(
      BuildContext context, List<DestinyItemInvestmentStatDefinition> stats) {
    if (stats == null || stats.length == 0) {
      return Container();
    }

    List<Widget> statList = stats.map<Widget>((stat) {
      var values = StatValues();
      values.selected = stat.value;
      return ItemStatWidget(stat.statTypeHash, 0, values);
    }).toList();
    return Container(
        color: Colors.blueGrey.shade900,
        margin: EdgeInsets.all(4),
        child: Column(children: [
          Container(
              constraints: BoxConstraints(minWidth: double.infinity),
              color: Colors.black,
              alignment: Alignment.center,
              padding: EdgeInsets.all(4),
              child: TranslatedTextWidget("Stats",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.w700))),
          Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: statList,
              ))
        ]));
  }
}
