//@dart=2.12

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/side_menu/side_menu.widget.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({Key? key}) : super(key: key);

  @override
  _EquipmentPageState createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> with ProfileConsumer {
  List<DestinyCharacterComponent>? _characters;
  List<DestinyCharacterComponent> get characters {
    return _characters ??= profile.getCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: SideMenuWidget(
          onPageChange: (page) {},
        ),
        body: buildCharacters());
  }

  Widget buildCharacters() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: characters.map((c) {
          return Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  // c.embManifestImageWidget<DestinyInventoryItemDefinition>(c.emblemHash),
                  // ManifestText<DestinyClassDefinition>(c.classHash),
                  // Text("${c.light}")
                ],
              ));
        }).toList());
  }
}
