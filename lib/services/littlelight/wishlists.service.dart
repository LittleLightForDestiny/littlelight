import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:http/http.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/profile/profile.service.dart';

class WishlistsService {
  static final WishlistsService _singleton = new WishlistsService._internal();
  factory WishlistsService() {
    return _singleton;
  }
  WishlistsService._internal();

  Map<int, WishList> _wishlists = Map();

  String _text;

  reset() {
    _wishlists = null;
  }

  load(String url) async {
    url =
        "https://raw.githubusercontent.com/48klocs/dim-wish-list-sources/master/voltron.txt";
    var text = _text ?? (await get(url)).body;
    _text = text;
    var lines = text.split('\n');
    String notes;
    WishlistTag specialty;
    for (var line in lines) {
      specialty = _getSpecialtyByLine(line) ?? specialty;
      notes = _getNotesByLine(line) ?? notes;
      if (line.contains("dimwishlist:") || line.contains("llwishlist:")) {
        _addLineToWishList(line, specialty, notes);
      }
    }
  }

  Set<WishlistTag> getPerkSpecialties(
      int itemHash, int plugItemHash) {
    var wishlist = _wishlists[itemHash];
    if(wishlist?.perks == null) return Set();
    return _wishlists[itemHash]?.perks[plugItemHash] ?? Set();
  }

  WishListBuild getWishlistBuild(DestinyItemComponent item) {
    if (item == null) return null;
    var sockets = ProfileService().getItemReusablePlugs(item.itemInstanceId);
    var availablePlugs = sockets?.values
        ?.map((plugs) => plugs.map((plug) => plug.plugItemHash))
        ?.fold<Set<int>>(Set(), (t, i) => t.followedBy(i).toSet());
    if(availablePlugs == null) return null;
    var wish = _wishlists[item?.itemHash];
    return wish?.builds?.values?.firstWhere((build){
      return availablePlugs.containsAll(build.perks);
    }, orElse:()=>null);
  }

  WishlistTag _getSpecialtyByLine(String line) {
    if (line.contains("//") || line.contains("#notes:")) {
      if (line.toLowerCase().contains("pve"))
        return WishlistTag.PVE;
      if (line.toLowerCase().contains("pvp"))
        return WishlistTag.PVP;
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
      String line, WishlistTag specialty, String notes) {
    var itemHashRegexp = RegExp(r"item=(\d*?)\D", caseSensitive: false);
    var itemHashStr = itemHashRegexp.firstMatch(line)?.group(1);
    var perksRegexp = RegExp(r"perks=([0-9,]*)", caseSensitive: false);
    var perksStr = perksRegexp.firstMatch(line)?.group(1);
    if (perksStr == null || itemHashStr == null) return;

    var perks = perksStr?.split(",")?.map((p) => int.parse(p))?.toList();
    var hash = int.parse(itemHashStr);
    perks?.sort();
    var buildId = perks.join('_');
    var wishlist =
        _wishlists[hash] = _wishlists[hash] ?? WishList.builder(itemHash: hash);
    var build = wishlist.builds[buildId] = wishlist.builds[buildId] ??
        WishListBuild.builder(identifier: buildId, perks: perks.toSet());
    build.notes.add(notes);
    build.tags.add(specialty);
    for (var i in perks) {
      var perk = wishlist.perks[i] = wishlist.perks[i] ?? Set();
      perk.add(specialty);
    }
  }
}
