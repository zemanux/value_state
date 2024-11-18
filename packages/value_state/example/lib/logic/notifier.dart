import 'package:flutter/foundation.dart';
import 'package:value_state/value_state.dart';

import 'repository.dart';

class CounterNotifier extends ValueNotifier<Value<int>> {
  CounterNotifier() : super(const Value.initial()) {
    increment();
  }

  final _myRepository = MyRepository();

  void increment() {
    value.fetch(_myRepository.getValue).forEach((state) {
      value = state;
    });
  }
}
