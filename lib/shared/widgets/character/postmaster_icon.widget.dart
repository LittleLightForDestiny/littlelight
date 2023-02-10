import 'package:flutter/material.dart';
import 'package:little_light/shared/widgets/character/base_character_icon.widget.dart';

class PostmasterIconWidget extends BaseCharacterIconWidget {
  const PostmasterIconWidget({double borderWidth = 1.5}) : super(borderWidth: borderWidth);
  @override
  Widget buildIcon(BuildContext context) => Image.asset("assets/imgs/postmaster-icon.jpg");
}
