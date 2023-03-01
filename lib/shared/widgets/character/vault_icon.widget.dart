import 'package:flutter/material.dart';
import 'package:little_light/shared/widgets/character/base_character_icon.widget.dart';

class VaultIconWidget extends BaseCharacterIconWidget {
  const VaultIconWidget({double borderWidth = 1.5})
      : super(borderWidth: borderWidth);
  @override
  Widget buildIcon(BuildContext context) =>
      Image.asset("assets/imgs/vault-icon.jpg");
}
