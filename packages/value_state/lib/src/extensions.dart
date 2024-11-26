import 'fetch.dart';
import 'value.dart';

extension ValueExtensions<T extends Object> on Value<T> {
  /// Provides a concise way to map a value depending on the [Value.state] of
  /// this value.
  /// * [initial] is called if this value is [Value.isInitial],
  /// * [success] is called if this value is [Value.isSuccess], [Value.data] is
  ///   then available as parameter,
  /// * [data] is called if this value has [Value.data] available as parameter,
  /// * [failure] is called if this value is [Value.isFailure], and
  ///   [Value.error] is then available as parameter,
  /// * [orElse] is called if none of the above match or not specified. This
  ///   parameter is required.
  R map<R>({
    R Function()? initial,
    R Function(T data)? success,
    R Function(T data)? data,
    R Function(Object error)? failure,
    required R Function() orElse,
  }) =>
      switch (this) {
        Value<T>(isInitial: true) when initial != null => initial(),
        Value<T>(:final dataOnSuccess?) when success != null =>
          success(dataOnSuccess),
        Value<T>(data: final dataOfThis?) when data != null => data(dataOfThis),
        Value<T>(isFailure: true, :final error?) when failure != null =>
          failure(error),
        _ => orElse(),
      };

  /// Provides a concise way to execute an action or map a value depending on
  /// the [Value.state] of this value.
  /// * [initial] is called if this value is [Value.isInitial],
  /// * [success] is called if this value is [Value.isSuccess], [Value.data] is
  ///   then available as parameter,
  /// * [data] is called if this value has [Value.data] available as parameter,
  /// * [failure] is called if this value is [Value.isFailure], and
  ///   [Value.error] is then available as parameter,
  /// * [orElse] is called if none of the above match or not specified.
  ///
  /// If none of those parameters are specified or does not match, then this
  /// method returns `null`.
  R? when<R>({
    R Function()? initial,
    R Function(T data)? success,
    R Function(T data)? data,
    R Function(Object error)? failure,
    R Function()? orElse,
  }) =>
      map<R?>(
        initial: initial,
        success: success,
        data: data,
        failure: failure,
        orElse: orElse ?? () => null,
      );
}

extension FutureValueStateExtension<T extends Object> on Future<T> {
  /// Generate a stream of [Value] during a processing [Future].
  Stream<Value<T>> toValues({bool guarded = true}) => Value<T>.initial().fetch(
        () => this,
        guarded: guarded,
      );
}
