


import 'package:get_it/get_it.dart';
import 'package:little_light/services/selection/selection.service.dart';

extension SelectionConsumerExtension on SelectionConsumer{
  SelectionService? get selection => GetIt.I<SelectionService>();
}

mixin SelectionConsumer {}
