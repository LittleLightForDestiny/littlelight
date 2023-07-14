enum LittleLightRoutePage { Login, Main }

extension RouteName on LittleLightRoutePage {
  String get name => toString().split(".").last.toLowerCase();
}
