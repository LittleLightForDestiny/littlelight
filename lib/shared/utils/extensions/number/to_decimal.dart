import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DecimalFormatter on num {
  String? toDecimal(BuildContext context) {
    final formatter = NumberFormat.decimalPattern();
    final formattedValue = formatter.format(this);
    return formattedValue;
  }
}
