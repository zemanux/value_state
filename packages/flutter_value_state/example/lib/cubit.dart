import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_state/flutter_value_state.dart';

class CounterCubit extends Cubit<Value<int>> {
  var _value = 0;
  Future<int> _getMyValueFromRepository() async => _value++;

  CounterCubit() : super(Value.success(0)) {
    increment();
  }

  Future<void> increment() => state.fetch(() async {
        final result = await _getMyValueFromRepository();

        if (result == 2) {
          throw 'Error';
        } else {
          return result;
        }
      }).forEach(emit);
}
