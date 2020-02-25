import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';

class DimWishlistParser {
  Set<int> _itemHashes = Set();

  parse(String text) async {
    var lines = text.split('\n');

    Set<String> genericNotes = Set();
    Set<WishlistTag> genericTags = Set();
    for (var line in lines) {
      if (line.length == 0) {
        genericNotes = Set();
        genericTags = Set();
      }

      if (line.contains("dimwishlist:")) {
        Set<WishlistTag> tags = _getBuildTags(line, genericTags) ?? Set();
        Set<String> notes = Set();
        var note = _getBuildNotes(line); 
        if(note != null){
          notes.add(_getBuildNotes(line));
        }
        notes.addAll(genericNotes ?? Set());
        _addLineToWishList(line, tags, notes.followedBy(genericNotes).toSet());
      }else{
        var note = _getGenericNotes(line);
        if(note != null){
          genericNotes.add(_getGenericNotes(line));
        }
        var tags = _getGenericTags(line);
        if(tags != null){
          genericTags.addAll(tags);
        }
      }
    }
  }

  Set<WishlistTag> _getGenericTags(String line) {
    if (line.contains("//notes:")) {
      return _parseTags(line.substring(line.indexOf("//notes:") + 8));
    }
    if (line.contains("//")) {
      return _parseTags(line.substring(line.indexOf("//") + 2));
    }
    return null;
  }

  Set<WishlistTag> _getBuildTags(String line, Set<WishlistTag> genericTags) {
    if (line.contains("#notes:") && line.contains("|tags:")) {
      return _parseTags(line.substring(line.indexOf("|tags:") + 6));
    }
    if (line.contains("#notes:")) {
      return _parseTags(line.substring(line.indexOf("#notes:") + 7))?.followedBy(genericTags)?.toSet();
    }
    if((genericTags?.length ?? 0) > 0){
      return genericTags;
    }
    return null;
  }

  Set<WishlistTag> _parseTags(String tagsStr) {
    Set<WishlistTag> tags = Set();
    if (tagsStr.toLowerCase().contains("🤢🤢🤢") ||
        tagsStr.toLowerCase().contains("trash")) {
      tags.add(WishlistTag.Trash);
    }
    if (tagsStr.toLowerCase().contains("pve")) {
      tags.add(WishlistTag.PVE);
    }
    if (tagsStr.toLowerCase().contains("pvp")) {
      tags.add(WishlistTag.PVP);
    }

    if (tagsStr.toLowerCase().contains("curated")) {
      tags.add(WishlistTag.Bungie);
    }
    if (tags.length > 0) return tags;
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
      return line.substring(index + 7);
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
            ?.map((p) => [int.tryParse(p)])
            ?.where((p) => p != null)
            ?.toList() ??
        [];
    var hash = int.parse(itemHashStr);
    WishlistsService().addToWishList(null, hash, perks, specialties, notes);
    _itemHashes.add(hash);
  }
}
