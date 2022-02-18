import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';

class LoadoutProvider extends ChangeNotifier {
  Loadout loadout;

  LoadoutProvider(this.loadout);
}
