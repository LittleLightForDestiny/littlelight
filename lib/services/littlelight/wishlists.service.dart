//@dart=2.12
import 'dart:convert';

import 'package:bungie_api/destiny2.dart';
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
    this.builds.add(build);
    build.plugs.forEach((socket) {
      socket.forEach((plugHash) {
        final itemPlugs = perks[plugHash] ??= Set<WishlistTag>();
        itemPlugs.addAll(build.tags);
      });
    });
  }
}

final _notInitializedException = NotInitializedException("_parsedWishlists was not initialized");

class WishlistsService with StorageConsumer {
  ParsedWishlist? _parsedWishlists;
  Future<List<WishlistFile>?> getWishlists() => globalStorage.getWishlists();
  Future<void> setWishlists(List<WishlistFile> wishlists) async => await globalStorage.setWishlists(wishlists);
  WishlistsService._internal();

  Future<void> checkForUpdates() async {
    // _parsedWishlists = await globalStorage.getParsedWishlists();
    if (_parsedWishlists == null) {
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
    final items = Map<int, ParsedWishlistItem>();
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

    final fileContents = await globalStorage.getWishlistContent(wishlist);
    final webContents = await http.get(uri);
    try {
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

  Set<String> getWishlistBuildNotes({required int itemHash, Map<String, List<DestinyItemPlugBase>>? reusablePlugs}) {
    final builds = getWishlistBuilds(itemHash: itemHash, reusablePlugs: reusablePlugs);
    final descriptions = Set<String>();
    for(final build in builds){
      final description = build.description?.trim() ?? "";
      if(description.length == 0) break;
      descriptions.removeWhere((d) => description.contains(d));
      final alreadyExists = descriptions.any((d)=>d.contains(description));
      if(!alreadyExists) descriptions.add(description);
    }
    return descriptions;
  }

  Set<WishlistTag> getWishlistBuildTags({
    required int itemHash,
    required Map<String, List<DestinyItemPlugBase>> reusablePlugs,
  }) {
    final builds = getWishlistBuilds(itemHash: itemHash, reusablePlugs: reusablePlugs);
    final tags = builds.map((e) => e.tags.toList());
    if(tags.length == 0) return Set();
    return tags.reduce((value, element) => value + element).toSet();
  }

  Set<WishlistTag> getPlugTags(int itemHash, int plugItemHash) {
    if (_parsedWishlists == null) throw _notInitializedException;
    return _parsedWishlists?.items[itemHash]?.perks[plugItemHash] ?? Set();
  }

  addWishlist(WishlistFile wishlist) {
    ///TODO: get this method right;
  }

  removeWishlist(WishlistFile w) {
    ///TODO: get this method right;
  }

  List<ParsedWishlistBuild> getWishlistBuilds({required int itemHash, Map<String, List<DestinyItemPlugBase>>? reusablePlugs}) {
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
    if (availablePlugs.length == 0) return [];
    final builds = wishlistItem?.builds.where((build) {
      return build.plugs.every((element) => element.any((e) => availablePlugs.contains(e)) || element.length == 0);
    });

    return builds?.toList() ?? [];
  }
}
