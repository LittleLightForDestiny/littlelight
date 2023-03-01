import 'package:get_it/get_it.dart';
import 'package:little_light/models/item_notes.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';

import 'package:little_light/services/storage/export.dart';

final Map<String, ItemNotesTag> _defaultTags = {
  "favorite": ItemNotesTag.favorite(),
  "trash": ItemNotesTag.trash(),
  "infuse": ItemNotesTag.infuse(),
};

setupitemNotes() {
  GetIt.I.registerLazySingleton<ItemNotesService>(
      () => ItemNotesService._internal());
}

class ItemNotesService with StorageConsumer {
  ItemNotesService._internal();

  Map<String, ItemNotes>? _notes;
  Map<String?, ItemNotesTag>? _tags;

  reset() {
    _notes = null;
    _tags = null;
  }

  List<ItemNotesTag?>? tagsByIds(Set<String?>? ids) {
    if (ids == null) return null;
    return ids
        .map((i) {
          if (_defaultTags.containsKey(i)) return _defaultTags[i!];
          if (_tags?.containsKey(i) ?? false) return _tags![i];
          return null;
        })
        .where((t) => t != null)
        .toList();
  }

  List<ItemNotesTag> getAvailableTags() {
    return _defaultTags.values.toList() + (_tags?.values.toList() ?? []);
  }

  Future<Map<String, ItemNotes>> getNotes({forceFetch = false}) async {
    if (_notes != null && !forceFetch) return _notes!;

    await _loadNotesFromCache();
    if (forceFetch || _notes == null) await _fetchNotes();

    _notes = _notes ?? <String, ItemNotes>{};
    return _notes!;
  }

  Future<bool> _loadNotesFromCache() async {
    _notes = await currentMembershipStorage.getCachedNotes();
    _tags = await currentMembershipStorage.getCachedTags();
    return _notes != null && _tags != null;
  }

  Future<bool> _fetchNotes() async {
    var api = LittleLightApiService();
    try {
      var response = await api.fetchItemNotes();
      _notes = Map.fromEntries(response.notes.map((note) {
        return MapEntry(note.uniqueId, note);
      }));
      _tags = Map.fromEntries(response.tags.map((tag) {
        return MapEntry(tag.tagId, tag);
      }));
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  ItemNotes? getNotesForItem(int? itemHash, String? itemInstanceId,
      [bool orNew = false]) {
    if (_notes == null) return null;
    if (_notes!.containsKey("${itemHash}_$itemInstanceId")) {
      return _notes!["${itemHash}_$itemInstanceId"];
    }
    if (orNew) {
      _notes!["${itemHash}_$itemInstanceId"] = ItemNotes.fromScratch(
          itemHash: itemHash!, itemInstanceId: itemInstanceId);
      return _notes!["${itemHash}_$itemInstanceId"];
    }
    return null;
  }

  Set<ItemNotesTag>? getTagsForItem(int itemHash, String? itemInstanceId) {
    final notes = getNotesForItem(itemHash, itemInstanceId);
    final tags = notes?.tags;
    if (tags == null) return null;
    return tagsByIds(tags)?.whereType<ItemNotesTag>().toSet();
  }

  Future<bool> saveNotes(ItemNotes notes) async {
    final allNotes = _notes ?? await getNotes();
    allNotes[notes.uniqueId] = notes;
    await _saveNotesToStorage();
    final api = LittleLightApiService();
    final result = await api.saveItemNotes(notes);
    return result == 1;
  }

  Future<int> deleteTag(ItemNotesTag tag) async {
    _tags?.remove(tag.tagId);
    await _saveTagsToStorage();
    var api = LittleLightApiService();
    return await api.deleteTag(tag);
  }

  Future<int> saveTag(ItemNotesTag tag) async {
    _tags ??= {};
    _tags![tag.tagId] = tag;
    await _saveTagsToStorage();
    var api = LittleLightApiService();
    return await api.saveTag(tag);
  }

  Future<void> _saveTagsToStorage() async {
    await currentMembershipStorage
        .saveCachedTags(_tags as Map<String, ItemNotesTag>? ?? {});
  }

  Future<void> _saveNotesToStorage() async {
    await currentMembershipStorage.saveCachedNotes(_notes ?? {});
  }
}
