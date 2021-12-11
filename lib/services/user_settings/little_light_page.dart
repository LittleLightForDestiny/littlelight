//@dart=2.12
enum LittleLightPage {
  Equipment,
  Collections,
  Triumphs,
  Loadouts,
  Progress,
  DuplicatedItems,
  Search,
  Armory,
}

const publicPages = [
  LittleLightPage.Collections,
  LittleLightPage.Triumphs,
];

final Map<String, LittleLightPage> _nameToPageMap = LittleLightPage.values
    .asMap()
    .map((key, value) => MapEntry(value.name, value));

extension LittleLightPageName on LittleLightPage {
  String get name => this.toString().split(".").last;
}

containsPage() => LittleLightPage.values.contains("Test");

extension ContainsAsString on List<LittleLightPage> {
  LittleLightPage? findByName(String name) {
    if (!_nameToPageMap.containsKey(name)) return null;
    final _page = _nameToPageMap[name];
    if (this.contains(_page)) {
      return _page;
    }
    return null;
  }
}
