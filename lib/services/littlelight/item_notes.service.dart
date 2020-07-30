import 'package:little_light/models/item_notes.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/storage/storage.service.dart';

class ItemNotesService {
  static final ItemNotesService _singleton = new ItemNotesService._internal();
  factory ItemNotesService() {
    return _singleton;
  }
  ItemNotesService._internal();

  List<ItemNotes> _notes;

  reset() {
    _notes = null;
  }

  Future<List<ItemNotes>> getNotes({forceFetch: false}) async {
    if (_notes != null && !forceFetch) {
      return _notes;
    }
    await _loadNotesFromCache();
    print(_notes);
    if (forceFetch || _notes == null) {
      _notes = await _fetchNotes();
    }
    return _notes ?? [];
  }

  Future<List<ItemNotes>> _loadNotesFromCache() async {
    var storage = StorageService.membership();
    List<dynamic> json = await storage.getJson(StorageKeys.cachedNotes);
    if (json != null) {
      List<ItemNotes> notes = json.map((j) => ItemNotes.fromJson(j)).toList();
      this._notes = notes;
      return notes;
    }
    return null;
  }

  Future<List<ItemNotes>> _fetchNotes() async {
    var api = LittleLightApiService();
    List<ItemNotes> notes;
    try {
      notes = await api.fetchItemNotes();
    } catch (e) {
      print(e);
    }
    return notes ?? this._notes;
  }

  ItemNotes getNotesForItem(int itemHash, String itemInstanceId) {
    return _notes?.firstWhere(
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

  Future<int> deleteNotes(ItemNotes notes) async {
    // var api = LittleLightApiService();
    // return await api.deleteLoadout(loadout);
    return 0;
  }

  Future<void> _saveNotesToStorage() async {
    var storage = StorageService.membership();
    List<dynamic> json = _notes.map((l) => l.toJson()).toList();
    await storage.setJson(StorageKeys.cachedNotes, json);
  }
}
