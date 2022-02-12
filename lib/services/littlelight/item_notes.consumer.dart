//@dart=2.12
import 'package:get_it/get_it.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/littlelight/item_notes.service.dart';

ItemNotesService getInjecteditemNotes() => GetIt.I<ItemNotesService>();

extension ItemNotesServiceProvider on ItemNotesConsumer {
  ItemNotesService get itemNotes => getInjecteditemNotes();
}

mixin ItemNotesConsumer {}
