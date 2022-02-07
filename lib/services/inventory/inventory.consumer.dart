import 'package:get_it/get_it.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/inventory/inventory.service.dart';

extension InventoryConsumerExtension on InventoryConsumer {
  InventoryService? get inventory => GetIt.I<InventoryService>();
}

mixin InventoryConsumer {}
