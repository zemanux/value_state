import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_state/value_state.dart';

class CounterCubit extends Cubit<Value<int>> {
  final _myRepository = _MyRepository();

  CounterCubit() : super(const Value.initial()) {
    increment();
  }

  Future<void> increment() => state.fetch(_myRepository.getValue).forEach(emit);
}

class _MyRepository {
  var _value = 0;

  Future<int> getValue() async {
    // Emulate a network request delay
    await Future.delayed(const Duration(milliseconds: 500));

    final value = _value++;

    if (value == 2) {
      throw 'Error';
    }
    return value;
  }
}
