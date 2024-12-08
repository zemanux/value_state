import 'dart:async';

import 'package:value_state/value_state.dart';

typedef FetchOnValueEmitter<T extends Object> = FutureOr<void> Function(
    Value<T> value);
typedef FetchOnValueAction<T extends Object, R> = FutureOr<R> Function(
  Value<T> value,
  FetchOnValueEmitter<T> emitter,
);

Future<R> fetchOnValue<T extends Object, R>({
  required Value<T> Function() value,
  required FetchOnValueEmitter<T> emitter,
  required FetchOnValueAction<T, R> action,
  required bool lastValueOnError,
}) async {
  final valueBeforeFetch = value();

  try {
    final currentValue = valueBeforeFetch;
    final stateFetching = currentValue.copyWithFetching(true);

    if (currentValue != stateFetching) await emitter(stateFetching);

    return await action(value(), emitter);
  } catch (error, stackTrace) {
    final currentValue = lastValueOnError ? value() : valueBeforeFetch;

    await emitter(currentValue.toFailure(
      error,
      stackTrace: stackTrace,
      isFetching: false,
    ));

    rethrow;
  } finally {
    final currentValue = value();
    final stateFetchingEnd = currentValue.copyWithFetching(false);

    if (currentValue != stateFetchingEnd) await emitter(stateFetchingEnd);
  }
}
