import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_state/value_state.dart';

import 'repository.dart';

class CounterCubit extends Cubit<Value<int>> {
  final _myRepository = MyRepository();

  CounterCubit() : super(const Value.initial()) {
    increment();
  }

  Future<void> increment() => state.fetch(_myRepository.getValue).forEach(emit);
}
