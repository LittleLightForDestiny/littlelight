import 'base_filter_values_options.dart';

class ItemOwnerValues {
  Set<String> characters;
  bool vault;
  bool profile;

  ItemOwnerValues({
    Set<String>? characters,
    this.vault = false,
    this.profile = false,
  }) : this.characters = characters ?? {};

  ItemOwnerValues clone() => ItemOwnerValues(
      characters: characters.toSet(), vault: vault, profile: profile);

  bool get isEmpty => length == 0;
  int get length => characters.length + (vault ? 1 : 0) + (profile ? 1 : 0);
  void clear() {
    characters.clear();
    vault = false;
    profile = false;
  }
}

class ItemOwnerFilterOptions extends BaseFilterOptions<ItemOwnerValues> {
  ItemOwnerFilterOptions(ItemOwnerValues availableValues)
      : super(
          availableValues.clone(),
          availableValues: availableValues,
        );
}
