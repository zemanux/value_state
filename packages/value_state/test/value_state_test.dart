// ignore_for_file: prefer_const_constructors

import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

void main() {
  const value = 0;
  const error = 'Error';

  test('test getters', () {
    final initial = Value<int>.initial();

    expect(initial.isInitial, isTrue);
    expect(initial.isFetching, isFalse);
    expect(initial.isSuccess, isFalse);
    expect(initial.isFailure, isFalse);
    expect(initial.hasData, isFalse);
    expect(initial.hasError, isFalse);
    expect(initial.hasStackTrace, isFalse);
    expect(() => initial.data, throwsA(isA<StateError>()));
    expect(() => initial.error, throwsA(isA<StateError>()));
    expect(() => initial.stackTrace, throwsA(isA<StateError>()));

    final fetching = Value<int>.initial(isFetching: true);

    expect(fetching.isInitial, isTrue);
    expect(fetching.isFetching, isTrue);
    expect(fetching.isSuccess, isFalse);
    expect(fetching.isFailure, isFalse);
    expect(fetching.hasData, isFalse);
    expect(fetching.hasError, isFalse);
    expect(fetching.hasStackTrace, isFalse);
    expect(() => initial.data, throwsA(isA<StateError>()));
    expect(() => initial.error, throwsA(isA<StateError>()));
    expect(() => fetching.stackTrace, throwsA(isA<StateError>()));

    final success = Value.success(value);

    expect(success.isInitial, isFalse);
    expect(success.isFetching, isFalse);
    expect(success.isSuccess, isTrue);
    expect(success.isFailure, isFalse);
    expect(success.hasData, isTrue);
    expect(success.hasError, isFalse);
    expect(success.hasStackTrace, isFalse);
    expect(success.data, value);
    expect(() => initial.error, throwsA(isA<StateError>()));
    expect(() => success.stackTrace, throwsA(isA<StateError>()));

    final successWithNullData = Value<int?>.success(null);

    expect(successWithNullData.isInitial, isFalse);
    expect(successWithNullData.isFetching, isFalse);
    expect(successWithNullData.isSuccess, isTrue);
    expect(successWithNullData.isFailure, isFalse);
    expect(successWithNullData.hasData, isTrue);
    expect(successWithNullData.hasError, isFalse);
    expect(successWithNullData.hasStackTrace, isFalse);
    expect(() => initial.data, throwsA(isA<StateError>()));
    expect(() => initial.error, throwsA(isA<StateError>()));
    expect(
      () => successWithNullData.stackTrace,
      throwsA(isA<StateError>()),
    );

    final failure = Value<int>.failure(error);

    expect(failure.isInitial, isFalse);
    expect(failure.isFetching, isFalse);
    expect(failure.isSuccess, isFalse);
    expect(failure.isFailure, isTrue);
    expect(failure.hasData, isFalse);
    expect(failure.hasError, isTrue);
    expect(failure.hasStackTrace, isFalse);
    expect(() => initial.data, throwsA(isA<StateError>()));
    expect(failure.error, error);
    expect(failure.stackTrace, isNull);

    final failureWithData = success.toFailure(error);

    expect(failureWithData.isInitial, isFalse);
    expect(failureWithData.isFetching, isFalse);
    expect(failureWithData.isSuccess, isFalse);
    expect(failureWithData.isFailure, isTrue);
    expect(failureWithData.hasData, isTrue);
    expect(failureWithData.hasError, isTrue);
    expect(failureWithData.hasStackTrace, isFalse);
    expect(failureWithData.data, value);
    expect(failureWithData.error, error);
    expect(failureWithData.stackTrace, isNull);
  });

  test('test equalities and hash', () {
    // Dont create object with [const] to avoid [identical] return true
    final init1 = Value<int>.initial(), init2 = Value<int>.initial();

    expect(init1, init2);
    expect(init1.hashCode, init2.hashCode);

    final fetching1 = Value<int>.initial(isFetching: true),
        fetching2 = Value<int>.initial(isFetching: true);

    expect(fetching1, fetching2);
    expect(fetching1.hashCode, fetching2.hashCode);

    final success1 = Value.success(value), success2 = Value.success(value);

    expect(success1, success2);
    expect(success1.hashCode, success2.hashCode);

    final failure1 = Value<int>.failure(error),
        failure2 = Value<int>.failure(error);

    expect(failure1, failure2);
    expect(failure1.hashCode, failure2.hashCode);

    final failureWithData1 = success1.toFailure(error),
        failureWithData2 = success2.toFailure(error);

    expect(failureWithData1, failureWithData2);
    expect(failureWithData1.hashCode, failureWithData2.hashCode);
  });

  test('test toString', () {
    expect(const Value<String>.initial().toString(),
        'Value<String>(state: ValueState.initial, isFetching: false)');

    final value = Value.success('My value');

    expect(
        value.toString(),
        'Value<String>(state: ValueState.success, isFetching: false, '
        'data: My value)');
    expect(
        value.toFailure(ArgumentError()).toString(),
        'Value<String>(state: ValueState.failure, isFetching: false, '
        'data: My value, error: Invalid argument(s))');

    expect(
        Value<String>.failure(ArgumentError()).toString(),
        'Value<String>(state: ValueState.failure, isFetching: false, '
        'error: Invalid argument(s))');
  });
}
