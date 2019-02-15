import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/item_category.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class CreditsScreen extends StatelessWidget {
  final profile = new ProfileService();
  final manifest = new ManifestService();
  final List<int> itemTypes = [
    ItemCategory.weapon,
    ItemCategory.armor,
    ItemCategory.inventory
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/imgs/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
              child: Container(
                padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                border: Border(
                    bottom: BorderSide(width: 4, color: Colors.blueGrey),
                    top: BorderSide(width: 4, color: Colors.blueGrey))),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TranslatedTextWidget(
                      "Little Light is brought to you by your fellow guardian"),
                ]),
          ))),
    );
  }
}
