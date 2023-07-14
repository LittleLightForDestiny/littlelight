import 'package:flutter/material.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/scoped_value_repository.bloc.dart';
import 'package:provider/provider.dart';
export 'scoped_value_repository.bloc.dart' show StorableValue;

extension PageStorageHelper on BuildContext {
  storeValue<T extends StorableValue>(T param) => this.read<ScopedValueRepositoryBloc>().storeValue(param);
  T? readValue<T extends StorableValue>(T param) => this.watch<ScopedValueRepositoryBloc>().getValue(param);
}
