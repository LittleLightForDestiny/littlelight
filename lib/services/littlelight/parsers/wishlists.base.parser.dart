//@dart=2.12
import 'package:little_light/models/parsed_wishlist.dart';

abstract class WishlistBaseParser {
  Future<List<ParsedWishlistBuild>> parse(String content);
}
