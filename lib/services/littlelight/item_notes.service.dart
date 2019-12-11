import 'package:little_light/models/item_notes.dart';
import 'package:little_light/models/loadout.dart';
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
    if (forceFetch) {
      await _fetchnotes();
    }
    return _notes;
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

  Future<List<ItemNotes>> _fetchnotes() async {
    
  }

  Future<int> saveNotes(ItemNotes loadout) async {
    await _saveNotesToStorage();
    // var api = LittleLightApiService();
    // return await api.saveLoadout(loadout);
    return 1;
  }

  Future<int> deleteNotes(ItemNotes loadout) async {
    // var api = LittleLightApiService();
    // return await api.deleteLoadout(loadout);
  }

  Future<void> _saveNotesToStorage() async {
    var storage = StorageService.membership();
    List<dynamic> json = _notes.map((l) => l.toJson()).toList();
    await storage.setJson(StorageKeys.cachedNotes, json);
  }
}
