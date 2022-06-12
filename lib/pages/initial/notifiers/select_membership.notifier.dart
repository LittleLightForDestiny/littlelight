import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.consumer.dart';

class SelectMembershipNotifier with ChangeNotifier, AuthConsumer {
  final BuildContext context;

  UserMembershipData? _currentAccount;
  UserMembershipData? get currentAccount => _currentAccount;

  List<UserMembershipData>? _otherAccounts;
  List<UserMembershipData>? get otherAccounts => _otherAccounts;

  SelectMembershipNotifier(this.context);

  void loadAccounts() async {
    final currentAccountID = auth.currentAccountID;
    if (currentAccountID != null) {
      _currentAccount = await auth.getMembershipDataForAccount(currentAccountID);
      notifyListeners();
    }
    final otherAccountIDs = auth.accountIDs?.where((element) => element != currentAccountID) ?? [];
    if (otherAccountIDs.length > 0) {
      final _accounts = <UserMembershipData>[];
      for (final accountID in otherAccountIDs) {
        final account = await auth.getMembershipDataForAccount(accountID);
        if (account != null) _accounts.add(account);
      }
      if (_accounts.length > 0) {
        _otherAccounts = _accounts;
        notifyListeners();
      }
    }
  }
}
