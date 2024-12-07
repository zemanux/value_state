import 'package:flutter/foundation.dart';
import 'package:value_state/value_state.dart';

import 'repository.dart';

class CounterNotifier extends ValueNotifier<Value<int>> {
  CounterNotifier() : super(const Value.initial()) {
    increment();
  }

  final _myRepository = MyRepository();

  Future<void> increment() =>
      value.fetch(_myRepository.getValue).forEach(setNotifierValue);
}

/// Add this extension on your Flutter project to make it easier to use.
extension ValueNotifierExtensions<T extends Object> on ValueNotifier {
  @protected
  void setNotifierValue(Value<T> newValue) {
    value = newValue;
  }
}
