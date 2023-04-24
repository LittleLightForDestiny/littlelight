import 'dart:convert';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/exceptions/not_initialized.exception.dart';
import 'package:little_light/models/littlelight_wishlist.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/services/littlelight/parsers/littlelight_wishlist.parser.dart';
import 'package:little_light/services/storage/storage.consumer.dart';

setupWishlistsService() {
  GetIt.I.registerSingleton<WishlistsService>(WishlistsService._internal());
}

extension on Map<int, ParsedWishlistItem> {
  ParsedWishlistItem? upsertItem(int? hash) {
    if (hash == null) return null;
    if (this[hash] == null) {
      this[hash] = ParsedWishlistItem(itemHash: hash);
    }
    return this[hash];
  }
}

extension on ParsedWishlistItem {
  ParsedWishlistItem? addBuild(ParsedWishlistBuild build) {
    builds.add(build);
    for (var socket in build.plugs) {
      for (var plugHash in socket) {
        final itemPlugs = perks[plugHash] ??= <WishlistTag>{};
        itemPlugs.addAll(build.tags);
      }
    }
    return this;
  }
}

final _notInitializedException = NotInitializedException("_parsedWishlists was not initialized");

class WishlistsService extends ChangeNotifier with StorageConsumer {
  ParsedWishlist? _parsedWishlists;
  Future<List<WishlistFile>?> getWishlists() => globalStorage.getWishlists();
  Future<void> setWishlists(List<WishlistFile> wishlists) async => await globalStorage.setWishlists(wishlists);
  WishlistsService._internal();

  Future<void> checkForUpdates([bool forceUpdate = false]) async {
    _parsedWishlists ??= await globalStorage.getParsedWishlists();
    if (_parsedWishlists == null || forceUpdate) {
      await _updateIfNeeded();
      return;
    }
    _updateIfNeeded();
  }

  Future<void> _updateIfNeeded() async {
    final wishlists = await getWishlists();
    if (wishlists == null) return;
    bool needsToReprocess = _parsedWishlists == null || true;
    for (final wishlist in wishlists) {
      final updated = await _updateWishlistFile(wishlist);
      needsToReprocess = needsToReprocess || updated;
    }
    if (!needsToReprocess) {
      return;
    }
    final items = <int, ParsedWishlistItem>{};
    for (final wishlist in wishlists) {
      final contents = await globalStorage.getWishlistContent(wishlist);
      if (contents == null) continue;
      final parsed = await LittleLightWishlistParser().parse(contents);
      for (final build in parsed) {
        final hash = build.hash;
        final item = items.upsertItem(hash);
        if (item == null) continue;
        item.addBuild(build);
      }
    }
    _parsedWishlists = ParsedWishlist(items);
    await globalStorage.saveParsedWishlists(_parsedWishlists!);
  }

  Future<bool> _updateWishlistFile(WishlistFile wishlist) async {
    final url = wishlist.url;
    if (url == null) return false;

    final uri = Uri.parse(url);
    final isWebUri = uri.isScheme('HTTP') || uri.isScheme('HTTPS');
    if (!isWebUri) return false;

    try {
      final fileContents = await globalStorage.getWishlistContent(wishlist);
      final webContents = await http.get(uri);
      final json = jsonDecode(webContents.body);
      LittleLightWishlist.fromJson(json);
      final updated = fileContents != webContents.body;
      if (updated) {
        await globalStorage.saveWishlistContents(wishlist, webContents.body);
      }
      return updated;
    } catch (_) {
      return false;
    }
  }

  Future<WishlistFile?> loadWishlistFromUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final content = await http.get(uri);
      final json = jsonDecode(content.body);
      LittleLightWishlist.fromJson(json);
      return WishlistFile(name: json["name"], description: json["description"], url: url);
    } catch (e) {
      return null;
    }
  }

  Set<String> getWishlistBuildNotes({required int itemHash, Map<String, List<DestinyItemPlugBase>>? reusablePlugs}) {
    final builds = getWishlistBuilds(itemHash: itemHash, reusablePlugs: reusablePlugs);
    final descriptions = <String>{};
    for (final build in builds) {
      final description = build.description?.trim() ?? "";
      if (description.isEmpty) break;
      descriptions.removeWhere((d) => description.contains(d));
      final alreadyExists = descriptions.any((d) => d.contains(description));
      if (!alreadyExists) descriptions.add(description);
    }
    return descriptions;
  }

  Set<WishlistTag> getWishlistBuildTags({
    required int? itemHash,
    required Map<String, List<DestinyItemPlugBase>>? reusablePlugs,
  }) {
    if (itemHash == null) return {};
    final builds = getWishlistBuilds(itemHash: itemHash, reusablePlugs: reusablePlugs);
    final tags = builds.map((e) => e.tags.toList());
    if (tags.isEmpty) return <WishlistTag>{};
    final tagsSet = tags.reduce((value, element) => value + element).toSet();
    if (tagsSet.contains(WishlistTag.GodPVE)) tagsSet.remove(WishlistTag.PVE);
    if (tagsSet.contains(WishlistTag.GodPVP)) tagsSet.remove(WishlistTag.PVP);
    tagsSet.removeAll([
      WishlistTag.Controller,
      WishlistTag.Mouse,
    ]);
    return tagsSet.toSet();
  }

  Set<WishlistTag> getPlugTags(int itemHash, int plugItemHash) {
    if (_parsedWishlists == null) throw _notInitializedException;
    return _parsedWishlists?.items[itemHash]?.perks[plugItemHash] ?? <WishlistTag>{};
  }

  Future<List<WishlistFile>> addWishlist(WishlistFile wishlist) async {
    final wishlists = await getWishlists() ?? <WishlistFile>[];
    wishlists.removeWhere((element) => element.url == wishlist.url);
    wishlists.add(wishlist);
    await setWishlists(wishlists);
    await checkForUpdates(true);
    return wishlists;
  }

  Future<List<WishlistFile>> removeWishlist(WishlistFile wishlist) async {
    final wishlists = await getWishlists() ?? <WishlistFile>[];
    wishlists.removeWhere((element) => element.url == wishlist.url);
    await setWishlists(wishlists);
    await checkForUpdates(true);
    return wishlists;
  }

  List<ParsedWishlistBuild> getWishlistBuilds(
      {required int itemHash, Map<String, List<DestinyItemPlugBase>>? reusablePlugs}) {
    if (_parsedWishlists == null) throw _notInitializedException;
    final wishlistItem = _parsedWishlists?.items[itemHash];
    if (reusablePlugs == null) {
      return wishlistItem?.builds ?? [];
    }
    Set<int> availablePlugs = reusablePlugs.values
        .reduce((value, element) => value + element)
        .map((p) => p.plugItemHash)
        .whereType<int>()
        .toSet();
    if (availablePlugs.isEmpty) return [];
    final builds = wishlistItem?.builds.where((build) {
      return build.plugs.every((element) => element.any((e) => availablePlugs.contains(e)) || element.isEmpty);
    });

    return builds?.toList() ?? [];
  }
}
