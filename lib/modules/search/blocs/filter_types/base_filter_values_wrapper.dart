abstract class BaseFilterValuesWrapper<T> {
  final T _value;
  T get value => _value;

  final T? _availableValues;
  T? get availableValues => _availableValues;

  BaseFilterValuesWrapper(this._value, {T? availableValues}) : _availableValues = availableValues;
}
