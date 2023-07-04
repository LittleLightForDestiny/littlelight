import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/shared/widgets/character/base_character_icon.widget.dart';

class VaultIconWidget extends BaseCharacterIconWidget {
  const VaultIconWidget({
    double borderWidth = 1.5,
    double fontSize = characterIconDefaultFontSize,
    bool hideName = false,
  }) : super(
          borderWidth: borderWidth,
          fontSize: fontSize,
          hideName: hideName,
        );
  @override
  Widget buildIcon(BuildContext context) => Image.asset("assets/imgs/vault-icon.jpg");

  @override
  String? getName(BuildContext context) => "Vault".translate(context);
}
