//@dart=2.12

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
