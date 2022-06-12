import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';

Color? colorFromHex(String hex) {
  hex = hex.replaceAll("#", "");
  if (hex.length == 6) {
    hex = "FF" + hex;
  }
  if (hex.length == 8) {
    return Color(int.parse("0x$hex"));
  }
  return null;
}

String hexFromColor(Color color) {
  return "#${color.value.toRadixString(16)}";
}

extension ToMaterialColor on DestinyColor {
  Color toMaterialColor([double opacity = 1]) =>
      Color.fromRGBO(this.red ?? 0, this.green ?? 0, this.blue ?? 0, opacity);
}
