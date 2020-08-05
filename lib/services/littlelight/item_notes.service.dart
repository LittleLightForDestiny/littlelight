import 'package:little_light/models/item_notes.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/storage/storage.service.dart';

final Map<String, ItemNotesTag> _defaultTags = {
  "favorite": ItemNotesTag.favorite(),
  "trash": ItemNotesTag.trash(),
  "infuse": ItemNotesTag.infuse(),
};

class ItemNotesService {
  static final ItemNotesService _singleton = new ItemNotesService._internal();
  factory ItemNotesService() {
    return _singleton;
  }
  ItemNotesService._internal();

  Map<String, ItemNotes> _notes;
  Map<String, ItemNotesTag> _tags;

  reset() {
    _notes = null;
    _tags = null;
  }

  List<ItemNotesTag> tagsByIds(Set<String> ids) {
    if (ids == null) return null;
    return ids
        ?.map((i) {
          if (_defaultTags.containsKey(i)) return _defaultTags[i];
          if (_tags?.containsKey(i) ?? false) return _tags[i];
          return null;
        })
        ?.where((t) => t != null)
        ?.toList();
  }

  List<ItemNotesTag> getAvailableTags() {
    return _defaultTags.values.toList() + (_tags?.values?.toList() ?? []);
  }

  Future<Map<String, ItemNotes>> getNotes({forceFetch: false}) async {
    if (_notes != null && !forceFetch) {
      return _notes;
    }
    await _loadNotesFromCache();
    if (forceFetch || _notes == null) {
      await _fetchNotes();
    }
    return _notes ?? Map();
  }

  Future<bool> _loadNotesFromCache() async {
    var storage = StorageService.membership();
    List<dynamic> notesJson = await storage.getJson(StorageKeys.cachedNotes);
    List<dynamic> tagsJson = await storage.getJson(StorageKeys.cachedTags);

    if (notesJson != null && tagsJson != null) {
      _notes = Map.fromEntries(notesJson.map((j) {
        var note = ItemNotes.fromJson(j);
        return MapEntry(note.uniqueId, note);
      }));
      _tags = Map.fromEntries(tagsJson.map((j) {
        var tag = ItemNotesTag.fromJson(j);
        return MapEntry(tag.tagId, tag);
      }));
      return true;
    }

    return false;
  }

  Future<bool> _fetchNotes() async {
    var api = LittleLightApiService();
    try {
      var response = await api.fetchItemNotes();
      _notes = Map.fromEntries(response.notes?.map((note) {
        return MapEntry(note.uniqueId, note);
      }));
      _tags = Map.fromEntries(response.tags?.map((tag) {
        return MapEntry(tag.tagId, tag);
      }));
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  ItemNotes getNotesForItem(int itemHash, String itemInstanceId,
      [bool orNew = false]) {
    if (_notes == null) return null;
    if (_notes.containsKey("${itemHash}_$itemInstanceId")) {
      return _notes["${itemHash}_$itemInstanceId"];
    }
    if (orNew) {
      _notes["${itemHash}_$itemInstanceId"] = ItemNotes.fromScratch(
          itemHash: itemHash, itemInstanceId: itemInstanceId);
      return _notes["${itemHash}_$itemInstanceId"];
    }
    return null;
  }

  Future<int> saveNotes(ItemNotes notes) async {
    var allNotes = await this.getNotes();
    allNotes[notes.uniqueId] = notes;
    await _saveNotesToStorage();
    var api = LittleLightApiService();
    return await api.saveItemNotes(notes);
  }

  Future<int> deleteTag(ItemNotesTag tag) async {
    _tags?.remove(tag.tagId);
    await _saveTagsToStorage();
    var api = LittleLightApiService();
    return await api.deleteTag(tag);
  }

  Future<int> saveTag(ItemNotesTag tag) async {
    if (_tags == null) {
      _tags = Map();
    }
    _tags[tag.tagId] = tag;
    await _saveTagsToStorage();
    var api = LittleLightApiService();
    return await api.saveTag(tag);
  }

  Future<void> _saveTagsToStorage() async {
    var storage = StorageService.membership();
    List<dynamic> json = _tags?.values?.map((l) => l.toJson())?.toList() ?? [];
    await storage.setJson(StorageKeys.cachedTags, json);
  }

  Future<void> _saveNotesToStorage() async {
    var storage = StorageService.membership();
    List<dynamic> json = _notes?.values
            ?.where((element) =>
                (element?.notes?.length ?? 0) > 0 ||
                (element?.customName?.length ?? 0) > 0 ||
                (element?.tags?.length ?? 0) > 0)
            ?.map((l) => l.toJson())
            ?.toList() ??
        [];
    await storage.setJson(StorageKeys.cachedNotes, json);
  }
}
