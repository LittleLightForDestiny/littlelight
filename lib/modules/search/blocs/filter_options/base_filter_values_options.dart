abstract class BaseFilterOptions<T> {
  T _value;
  set value(T value) => _value = value;
  T get value => _value;

  T _availableValues;
  T get availableValues => _availableValues;
  set availableValues(T values) => _availableValues = values;

  bool _enabled;
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  bool get available => true;

  BaseFilterOptions(this._value,
      {required T availableValues, bool enabled = false})
      : _availableValues = availableValues,
        _enabled = enabled;
}
