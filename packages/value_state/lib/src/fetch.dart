import 'dart:async';

import 'extensions.dart';
import 'value.dart';

typedef FetchOnValueEmitter<T> = FutureOr<void> Function(Value<T> value);
typedef FetchOnValueAction<T, R> = FutureOr<R> Function(
  Value<T> value,
  FetchOnValueEmitter<T> emitter,
);

/// Handle states (isFetching, success, error...) while an [action] is
/// processed.
/// [value] must return the value updated.
/// If [errorAsValue] is `true` and [action] raise an exception then an
/// [Value._failure] is emitted. if `false`, nothing is emitted. The exception
/// is always rethrown by [fetchOnValue] to be handled by the caller.
Future<R> fetchOnValue<T, R>({
  required Value<T> Function() value,
  required FetchOnValueEmitter<T> emitter,
  required FetchOnValueAction<T, R> action,
  bool errorAsValue = true,
}) async {
  try {
    final currentState = value();
    final stateRefreshing = currentState.copyWithFetching(true);

    if (currentState != stateRefreshing) await emitter(stateRefreshing);

    return await action(value(), emitter);
  } catch (error, stackTrace) {
    if (errorAsValue) {
      await emitter(value().toFailure(
        error,
        stackTrace: stackTrace,
        isFetching: false,
      ));
    }
    rethrow;
  } finally {
    final currentState = value();
    final stateRefreshingEnd = currentState.copyWithFetching(false);

    if (currentState != stateRefreshingEnd) await emitter(stateRefreshingEnd);
  }
}

extension ValueStatePerformExtensions<T> on Value<T> {
  Stream<Value<T>> fetch(
    Future<Value<T>> Function() action, {
    bool guarded = true,
  }) {
    return fetchStream(action().asStream(), guarded: guarded);
  }

  Stream<Value<T>> fetchStream(Stream<Value<T>> stream, {bool guarded = true}) {
    final controller = StreamController<Value<T>>();
    var lastValue = this;

    fetchOnValue<T, void>(
      value: () => lastValue,
      emitter: (value) {
        lastValue = value;
        controller.add(value);
      },
      action: (value, emit) => stream.forEach(emit),
    ).onError((error, stackTrace) {
      if (error != null && !guarded) {
        throw error;
      }
    }).whenComplete(() {
      controller.close();
    });

    return controller.stream;
  }
}
