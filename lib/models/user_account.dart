import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/models/user_membership_data.dart';

class UserAccount {
  UserMembershipData membershipData;
  BungieNetToken token;
  DateTime lastUpdated;
}