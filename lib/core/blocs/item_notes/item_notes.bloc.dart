import 'package:flutter/material.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/models/item_notes.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/storage/export.dart';

class ItemNotesBloc extends ChangeNotifier with StorageConsumer {
  final BuildContext context;

  LittleLightApiService get _api => LittleLightApiService();
  Map<String, ItemNotesTag> get _defaultTags => {
        "favorite": ItemNotesTag.favorite(context),
        "trash": ItemNotesTag.trash(context),
        "infuse": ItemNotesTag.infuse(context),
      };

  ItemNotesBloc(this.context) {
    _loadAll();
  }

  bool _busy = false;
  Map<String, ItemNotes>? _notes;
  Map<String, ItemNotesTag>? _tags;

  Future<void> _loadAll() async {
    if (_busy) return;
    _busy = true;
    _notes = await currentMembershipStorage.getCachedNotes();
    _tags = await currentMembershipStorage.getCachedTags();
    notifyListeners();
    try {
      final remoteResponse = await _api.fetchItemNotes();
      final remoteNotes = remoteResponse.notes;
      final remoteTags = remoteResponse.tags;
      _notes = _mergeNotes(remoteNotes, _notes);
      _tags = _mergeTags(remoteTags, _tags);
    } catch (e, stackTrace) {
      logger.error("Error while trying to load remote notes/tags", error: e, stack: stackTrace);
    }
    _notes ??= {};
    _tags ??= {};
    _busy = false;
    notifyListeners();
  }

  Map<String, ItemNotes> _mergeNotes(List<ItemNotes> remoteNotes, Map<String, ItemNotes>? localNotes) {
    final remoteMap = <String, ItemNotes>{for (final n in remoteNotes) n.uniqueId: n};
    if (localNotes == null || localNotes.isEmpty) return remoteMap;
    final allIds = (remoteMap.keys.toList() + localNotes.keys.toList()).toSet();
    final mergedMap = <String, ItemNotes>{};
    for (final id in allIds) {
      final remoteNote = remoteMap[id];
      final localNote = localNotes[id];
      final remoteNoteDate = remoteNote?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final localNoteDate = localNote?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final newer = localNoteDate.isAfter(remoteNoteDate) ? localNote : remoteNote ?? localNote;
      if (newer != null) {
        mergedMap[id] = newer;
      }
    }
    return mergedMap;
  }

  Map<String, ItemNotesTag> _mergeTags(List<ItemNotesTag> remoteTags, Map<String, ItemNotesTag>? localTags) {
    final remoteMap = <String, ItemNotesTag>{for (final t in remoteTags) t.tagId ?? "": t};
    remoteMap.remove("");
    if (localTags == null || localTags.isEmpty) return remoteMap;
    final allIds = (remoteMap.keys.toList() + localTags.keys.toList()).toSet();
    final mergedMap = <String, ItemNotesTag>{};
    for (final id in allIds) {
      final remoteNote = remoteMap[id];
      final localNote = localTags[id];
      final remoteNoteDate = remoteNote?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final localNoteDate = localNote?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final newer = localNoteDate.isAfter(remoteNoteDate) ? localNote : remoteNote ?? localNote;
      if (newer != null) {
        mergedMap[id] = newer;
      }
    }
    return mergedMap;
  }

  Map<String, ItemNotes>? get allNotes {
    if (_notes == null) {
      _loadAll();
    }
    return _notes;
  }

  Map<String, ItemNotesTag>? get allCustomTags {
    if (_tags == null) {
      _loadAll();
    }
    return _tags;
  }

  List<ItemNotesTag> get availableTags {
    final customTags = allCustomTags?.values.toList() ?? [];
    return _defaultTags.values.toList() + customTags;
  }

  List<ItemNotesTag> tagsByIds(Set<String> ids) {
    return ids
        .map((i) {
          return _defaultTags[i] ?? _tags?[i];
        })
        .whereType<ItemNotesTag>()
        .toList();
  }

  void updateNotes(int itemHash, String? instanceId, {String? customName, String? notes}) {
    final id = ItemNotes.generateId(itemHash, instanceId);
    final itemNotes = _notes?[id] ?? ItemNotes.fromScratch(itemHash: itemHash, itemInstanceId: instanceId);
    _notes?[id] = itemNotes;
    if (customName != null) {
      itemNotes.customName = customName;
    }
    if (notes != null) {
      itemNotes.notes = notes;
    }

    notifyListeners();

    _saveNotesToStorage();
    _api.saveItemNotes(itemNotes);
  }

  void addTag(int itemHash, String? instanceId, String tag) {
    final id = ItemNotes.generateId(itemHash, instanceId);
    final notes = _notes?[id] ?? ItemNotes.fromScratch(itemHash: itemHash, itemInstanceId: instanceId);
    _notes?[id] = notes;
    final isAdded = notes.tags.contains(tag);
    if (isAdded) return;
    notes.tags.add(tag);

    notifyListeners();

    _saveNotesToStorage();
    _api.saveItemNotes(notes);
  }

  void removeTag(int itemHash, String? instanceId, String tag) {
    final id = ItemNotes.generateId(itemHash, instanceId);
    final notes = _notes?[id];
    if (notes == null) return;
    final isAdded = notes.tags.contains(tag);
    if (!isAdded) return;
    notes.tags.remove(tag);

    notifyListeners();

    _saveNotesToStorage();
    _api.saveItemNotes(notes);
  }

  String? customNameFor(int? itemHash, String? itemInstanceId) {
    if (itemHash == null) return null;
    final id = ItemNotes.generateId(itemHash, itemInstanceId);
    final customName = _notes?[id]?.customName;
    if (customName?.isEmpty ?? true) return null;
    return customName;
  }

  String? notesFor(int? itemHash, String? itemInstanceId) {
    if (itemHash == null) return null;
    final id = ItemNotes.generateId(itemHash, itemInstanceId);
    final notes = _notes?[id]?.notes;
    if (notes?.isEmpty ?? true) return null;
    return notes;
  }

  Set<String>? tagIdsFor(int? itemHash, String? itemInstanceId) {
    if (itemHash == null) return null;
    final id = ItemNotes.generateId(itemHash, itemInstanceId);
    final tags = _notes?[id]?.tags;
    return tags;
  }

  List<ItemNotesTag>? tagsFor(int? itemHash, String? itemInstanceId) {
    final tags = tagIdsFor(itemHash, itemInstanceId);
    if (tags == null) return null;
    return tagsByIds(tags);
  }

  bool hasTag(int? itemHash, String? itemInstanceId, String tag) {
    return tagIdsFor(itemHash, itemInstanceId)?.contains(tag) ?? false;
  }

  void deleteTag(ItemNotesTag tag) {
    final tags = _tags;
    if (tags == null) return;
    final exists = tags.containsKey(tag.tagId);
    if (!exists) return;
    tags.remove(tag.tagId);

    notifyListeners();

    _saveTagsToStorage();
    _api.deleteTag(tag);
  }

  void saveTag(ItemNotesTag tag) {
    final tags = _tags;
    final tagId = tag.tagId;
    if (tagId == null) return;
    if (tags == null) return;

    tags[tagId] = tag;

    _saveTagsToStorage();
    _api.saveTag(tag);
  }

  Future<void> _saveTagsToStorage() async {
    final tags = _tags;
    if (tags == null) return;
    await currentMembershipStorage.saveCachedTags(tags);
  }

  Future<void> _saveNotesToStorage() async {
    final notes = _notes;
    if (notes == null) return;
    await currentMembershipStorage.saveCachedNotes(notes);
  }
}
