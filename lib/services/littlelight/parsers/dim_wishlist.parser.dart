import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';

class DimWishlistParser {
  Set<int> _itemHashes = Set();
  Set<String> _buildIds = Set();

  parse(String text) async {
    var lines = text.split('\n');
    String notes;
    Set<WishlistTag> specialty;
    for (var line in lines) {
      specialty = _getSpecialtyByLine(line) ?? specialty ?? Set();
      notes = _getNotesByLine(line) ?? notes;
      if (line.contains("dimwishlist:")) {
        _addLineToWishList(line, specialty, notes);
      }
    }
  }

  Set<WishlistTag> _getSpecialtyByLine(String line) {
    if (line.contains("//") || line.contains("#notes:") || line.contains("//notes:")) {
      Set<WishlistTag> tags = Set();
      if (line.toLowerCase().contains("🤢🤢🤢")){
        tags.add(WishlistTag.Trash);
        return tags;
      }
      if (line.toLowerCase().contains("pve"))
        tags.add(WishlistTag.PVE);
      if (line.toLowerCase().contains("pvp"))
        tags.add(WishlistTag.PVP);
      
      if(line.toLowerCase().contains("curated") || line.toLowerCase().contains("masterwork"))
        tags.add(WishlistTag.Bungie);

      if(tags.length > 0) return tags;
    }
    return null;
  }

  String _getNotesByLine(String line) {
    if (line.contains("//notes:")) {
      return line.replaceAll("//notes:", "");
    }
    if (line.contains("#notes:")) {
      var index = line.indexOf("#notes:");
      return line.substring(index + 6);
    }
    return null;
  }

  _addLineToWishList(
      String line, Set<WishlistTag> specialties, String notes) {
    var itemHashRegexp = RegExp(r"item=-?(\d*?)\D", caseSensitive: false);
    var itemHashStr = itemHashRegexp.firstMatch(line)?.group(1);
    var perksRegexp = RegExp(r"perks=([0-9,]*)", caseSensitive: false);
    var perksStr = perksRegexp.firstMatch(line)?.group(1) ?? "";
    if (itemHashStr == null) return;
    var perks = perksStr?.split(",")?.map((p) => int.tryParse(p))?.where((p) => p!=null)?.toList() ?? [];
    perks?.sort();
    var hash = int.parse(itemHashStr);
    WishlistsService().addToWishList(hash, perks, specialties, notes);
    _itemHashes.add(hash);
    _buildIds.add("$hash #${perks.join('_')}");
  }
}
