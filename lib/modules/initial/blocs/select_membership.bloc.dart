import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';

class SelectMembershipBloc extends ChangeNotifier {
  final AuthService _auth;

  UserMembershipData? _currentAccount;
  UserMembershipData? get currentAccount => _currentAccount;

  List<UserMembershipData>? _otherAccounts;
  List<UserMembershipData>? get otherAccounts => _otherAccounts;

  SelectMembershipBloc({
    required AuthService auth,
  }) : this._auth = auth;

  void loadAccounts() async {
    final currentAccountID = _auth.currentAccountID;
    if (currentAccountID != null) {
      _currentAccount = await _auth.getMembershipDataForAccount(currentAccountID);
      notifyListeners();
    }
    final otherAccountIDs = _auth.accountIDs?.where((element) => element != currentAccountID) ?? [];
    if (otherAccountIDs.isNotEmpty) {
      final _accounts = <UserMembershipData>[];
      for (final accountID in otherAccountIDs) {
        final account = await _auth.getMembershipDataForAccount(accountID);
        if (account != null) _accounts.add(account);
      }
      if (_accounts.isNotEmpty) {
        _otherAccounts = _accounts;
        notifyListeners();
      }
    }
  }
}
