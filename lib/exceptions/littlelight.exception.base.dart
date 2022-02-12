//@dart=2.12
abstract class LittleLightBaseException implements Exception {
  final dynamic sourceError;
  LittleLightBaseException(this.sourceError);
}
