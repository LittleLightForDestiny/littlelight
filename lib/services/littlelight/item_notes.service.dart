import 'package:little_light/models/item_notes.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/storage/storage.service.dart';

class ItemNotesService {
  static final ItemNotesService _singleton = new ItemNotesService._internal();
  factory ItemNotesService() {
    return _singleton;
  }
  ItemNotesService._internal();

  NotesResponse _data;

  reset() {
    _data = null;
  }

  List<ItemNotesTag> tagsByIds(Set<String> ids) {
    if (ids == null) return null;
    var tags = getAvailableTags();
    return ids
        ?.map((i) => tags.firstWhere((t) => i == t.tagId, orElse: () => null))
        ?.where((t) => t != null)
        ?.toList();
  }

  List<ItemNotesTag> getAvailableTags() {
    return [
          ItemNotesTag.favorite(),
          ItemNotesTag.trash(),
          ItemNotesTag.infuse(),
        ] +
        (_data?.tags ?? []);
  }

  Future<List<ItemNotes>> getNotes({forceFetch: false}) async {
    if (_data != null && !forceFetch) {
      return _data.notes;
    }
    await _loadNotesFromCache();
    if (forceFetch || _data == null) {
      await _fetchNotes();
    }
    return _data?.notes ?? [];
  }

  Future<NotesResponse> _loadNotesFromCache() async {
    var storage = StorageService.membership();
    List<dynamic> notesJson = await storage.getJson(StorageKeys.cachedNotes);
    List<dynamic> tagsJson = await storage.getJson(StorageKeys.cachedTags);

    if (notesJson != null && tagsJson != null) {
      List<ItemNotes> notes =
          notesJson.map((j) => ItemNotes.fromJson(j)).toList();
      List<ItemNotesTag> tags =
          tagsJson.map((j) => ItemNotesTag.fromJson(j)).toList();
      this._data = NotesResponse(notes: notes, tags: tags);
      return this._data;
    }

    return null;
  }

  Future<NotesResponse> _fetchNotes() async {
    var api = LittleLightApiService();
    try {
      var response = await api.fetchItemNotes();
      this._data = response;
    } catch (e) {
      print(e);
    }
    return this._data;
  }

  ItemNotes getNotesForItem(int itemHash, String itemInstanceId) {
    return _data?.notes?.firstWhere(
            (n) => n.itemHash == itemHash && n.itemInstanceId == itemInstanceId,
            orElse: () => null) ??
        ItemNotes.fromScratch(
            itemHash: itemHash, itemInstanceId: itemInstanceId);
  }

  Future<int> saveNotes(ItemNotes notes) async {
    var allNotes = await this.getNotes();
    var index = allNotes.indexWhere((n) =>
        n.itemHash == notes.itemHash &&
        n.itemInstanceId == notes.itemInstanceId);
    if (index > -1) {
      allNotes[index] = notes;
    } else {
      allNotes.add(notes);
    }
    await _saveNotesToStorage();
    var api = LittleLightApiService();
    return await api.saveItemNotes(notes);
  }

  Future<int> deleteTag(ItemNotesTag tag) async {
    var allTags = this._data?.tags ?? [];
    allTags.removeWhere((n) => n.tagId == tag.tagId);
    await _saveTagsToStorage();
    var api = LittleLightApiService();
    return await api.deleteTag(tag);
  }

  Future<int> saveTag(ItemNotesTag tag) async {
    var allTags = this._data?.tags ?? [];
    // var json = tag.toJson();
    // tag.tagId = "custom_tag_${json["name"]}_${json["backgroundColorHex"]}";
    var index = allTags.indexWhere((n) => n.tagId == tag.tagId);
    if (index > -1) {
      allTags[index] = tag;
    } else {
      allTags.add(tag);
    }
    await _saveTagsToStorage();
    var api = LittleLightApiService();
    return await api.saveTag(tag);
  }

  Future<void> _saveTagsToStorage() async {
    var storage = StorageService.membership();
    List<dynamic> json = _data?.tags?.map((l) => l.toJson())?.toList() ?? [];
    await storage.setJson(StorageKeys.cachedTags, json);
  }

  Future<void> _saveNotesToStorage() async {
    var storage = StorageService.membership();
    List<dynamic> json = _data.notes.map((l) => l.toJson()).toList();
    await storage.setJson(StorageKeys.cachedNotes, json);
  }
}
