import 'dart:async';

import 'package:value_state/value_state.dart';

import 'fetch_on_value.dart';

extension ValueStateFetchExtensions<T extends Object> on Value<T> {
  Stream<Value<T>> fetch(
    Future<T> Function() action, {
    bool guarded = true,
  }) {
    return fetchStream(
      () => action().asStream().map(Value.success),
      guarded: guarded,
    );
  }

  /// Handle states (isFetching, success, error...) before and after the
  /// [stream] is processed :
  /// * Before the [stream] is processed, the value is emitted with
  ///   [Value.isFetching] set to true.
  /// * After the [stream] is processed, the last value is emitted with
  ///   [Value.isFetching] set to false.
  /// * If an exception is raised, an error is emitted based on the
  ///   [lastValueOnError] setting :
  ///    * If [lastValueOnError] is true, the most recent value emitted is used
  ///     to construct the error.
  ///    * If [lastValueOnError] is false, the value present before the stream
  ///     processing begins is used instead.
  ///
  /// If [guarded] is true, the error is not rethrown in the stream. If
  /// [guarded] is false, the error is rethrown in the stream.
  Stream<Value<T>> fetchStream(
    Stream<Value<T>> Function() stream, {
    bool guarded = true,
    bool lastValueOnError = false,
  }) {
    final controller = StreamController<Value<T>>();
    var lastValue = this;

    fetchOnValue<T, void>(
      value: () => lastValue,
      emitter: (value) {
        lastValue = value;
        controller.add(value);
      },
      action: (value, emit) => stream().forEach(emit),
      lastValueOnError: lastValueOnError,
    ).onError((error, stackTrace) {
      if (error != null && !guarded) {
        controller.addError(error, stackTrace);
      }
    }).whenComplete(() {
      controller.close();
    });

    return controller.stream;
  }
}
