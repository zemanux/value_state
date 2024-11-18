library value_state;

import 'fetch.dart';
import 'value.dart';

extension ValueExtensions<T> on Value<T> {
  /// Copy the actual object with fetching as [isFetching].
  Value<T> copyWithFetching(bool isFetching) =>
      merge(this, isFetching: isFetching);

  /// Convinient way to execute or map a value depending on the [Value.state] of
  /// this value.
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
      switch (this) {
        Value<T>(isInitial: true) when initial != null => initial(),
        Value<T>(isSuccess: true) when success != null => success(dataOrThrow),
        Value<T>(hasData: true, :final dataOrThrow) when data != null =>
          data(dataOrThrow),
        Value<T>(isFailure: true, :final error?) when failure != null =>
          failure(error),
        _ when orElse != null => orElse(),
        _ => null,
      };
}

extension FutureValueStateExtension<T> on Future<T> {
  /// Generate a stream of [Value] during a processing [Future].
  Stream<Value<T>> toValues({bool guarded = true}) => Value<T>.initial().fetch(
        () => this,
        guarded: guarded,
      );
}
