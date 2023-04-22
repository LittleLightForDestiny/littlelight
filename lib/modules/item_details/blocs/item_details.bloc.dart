import 'package:flutter/material.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/shared/models/transfer_destination.dart';

abstract class ItemDetailsBloc extends ChangeNotifier {
  @protected
  final BuildContext context;

  ItemDetailsBloc(this.context) : super();

  int? get itemHash;
  int? get styleHash;

  List<TransferDestination>? get transferDestinations;
  List<TransferDestination>? get equipDestinations;

  String? get customName;
  String? get itemNotes;
  List<ItemNotesTag>? get tags;
  void editNotes();
  void removeTag(ItemNotesTag tag);
  void editTags();

  bool? get isLocked;
  bool get isLockBusy;
  void changeLockState(bool newState);
}
