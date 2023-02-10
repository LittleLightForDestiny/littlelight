enum LittleLightPersistentPage {
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
  LittleLightPersistentPage.Collections,
  LittleLightPersistentPage.Triumphs,
];

final Map<String, LittleLightPersistentPage> _nameToPageMap =
    LittleLightPersistentPage.values.asMap().map((key, value) => MapEntry(value.name, value));

extension LittleLightPageName on LittleLightPersistentPage {
  String get name => toString().split(".").last;
}

containsPage() => LittleLightPersistentPage.values.contains("Test");

extension ContainsAsString on List<LittleLightPersistentPage> {
  LittleLightPersistentPage? findByName(String name) {
    if (!_nameToPageMap.containsKey(name)) return null;
    final _page = _nameToPageMap[name];
    if (contains(_page)) {
      return _page;
    }
    return null;
  }
}
