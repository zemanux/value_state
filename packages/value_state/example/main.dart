import 'dart:async';

import 'package:value_state/value_state.dart';

main() async {
  final delayedResults = Future<int>(() => 1).toValues();
  await printResults(delayedResults);

  // final delayedErrorResults = Future<int>.error('Error').toValues();
  // await printResults(delayedErrorResults);
}

Future<void> printResults(Stream<Value<int>> results) async {
  await for (final result in results) {
    switch (result) {
      case Value(isInitial: true):
        print('Initial - $result');
      case Value(isSuccess: true):
        print('Success - $result');
      case Value(isFailure: true):
        print('Failure - $result');
    }
  }
}
