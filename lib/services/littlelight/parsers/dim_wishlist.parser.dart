import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';

class DimWishlistParser {
  Set<int> _itemHashes = Set();
  Set<String> _buildIds = Set();

  parse(String text) async {
    var lines = text.split('\n');
    
    Set<String> genericNotes = Set();
    Set<WishlistTag> genericTags = Set();
    for (var line in lines) {
      if (line.length == 0) {
        genericNotes = Set();
        genericTags = Set();
      }
      genericNotes.add(_getGenericNotes(line));
      genericTags.addAll(_getGenericTags(line) ?? Set());

      if (line.contains("dimwishlist:")) {
        Set<WishlistTag> tags = _getBuildTags(line) ?? Set();
        Set<String> notes = Set();
        notes.add(_getBuildNotes(line));
        notes.addAll(genericNotes ?? Set());
        _addLineToWishList(line, tags.followedBy(genericTags).toSet(), notes.followedBy(genericNotes).toSet());
      }
    }
  }

  Set<WishlistTag> _getGenericTags(String line) {
    if (line.contains("//") || line.contains("//notes:")) {
      Set<WishlistTag> tags = Set();
      if (line.toLowerCase().contains("🤢🤢🤢")) {
        tags.add(WishlistTag.Trash);
      }
      if (line.toLowerCase().contains("pve")) {
        tags.add(WishlistTag.PVE);
      }
      if (line.toLowerCase().contains("pvp")) {
        tags.add(WishlistTag.PVP);
      }

      if (line.toLowerCase().contains("curated")) {
        tags.add(WishlistTag.Bungie);
      }

      if (tags.length > 0) return tags;
    }
    return null;
  }

  Set<WishlistTag> _getBuildTags(String line) {
    if (line.contains("#notes:")) {
      Set<WishlistTag> tags = Set();
      if (line.toLowerCase().contains("🤢🤢🤢")) {
        tags.add(WishlistTag.Trash);
      }
      if (line.toLowerCase().contains("pve")) {
        tags.add(WishlistTag.PVE);
      }
      if (line.toLowerCase().contains("pvp")) {
        tags.add(WishlistTag.PVP);
      }

      if (line.toLowerCase().contains("curated")) {
        tags.add(WishlistTag.Bungie);
      }

      if (tags.length > 0) return tags;
    }
    return null;
  }

  String _getGenericNotes(String line) {
    if (line.contains("//notes:")) {
      return line.replaceAll("//notes:", "");
    }
    return null;
  }

  String _getBuildNotes(String line) {
    if (line.contains("#notes:")) {
      var index = line.indexOf("#notes:");
      return line.substring(index + 6);
    }
    return null;
  }

  _addLineToWishList(
      String line, Set<WishlistTag> specialties, Set<String> notes) {
    var itemHashRegexp = RegExp(r"item=-?(\d*?)\D", caseSensitive: false);
    var itemHashStr = itemHashRegexp.firstMatch(line)?.group(1);
    var perksRegexp = RegExp(r"perks=([0-9,]*)", caseSensitive: false);
    var perksStr = perksRegexp.firstMatch(line)?.group(1) ?? "";
    if (itemHashStr == null) return;
    var perks = perksStr
            ?.split(",")
            ?.map((p) => int.tryParse(p))
            ?.where((p) => p != null)
            ?.toList() ??
        [];
    perks?.sort();
    var hash = int.parse(itemHashStr);
    WishlistsService().addToWishList(hash, perks, specialties, notes);
    _itemHashes.add(hash);
    _buildIds.add("$hash #${perks.join('_')}");
  }
}
