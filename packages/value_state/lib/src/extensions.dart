import 'fetch.dart';
import 'value.dart';

extension ValueExtensions<T> on Value<T> {
  Value<T> toSuccess(T data, {bool? isFetching}) => merge(
        Value.success(data),
        mapData: (from) => data,
        isFetching: isFetching,
      );

  Value<T> toFailure(
    Object error, {
    StackTrace? stackTrace,
    bool? isFetching,
  }) =>
      merge(
        Value.failure(error, stackTrace: stackTrace),
        isFetching: isFetching,
      );

  /// Copy the actual object with fetching as [isFetching].
  Value<T> copyWithFetching(bool isFetching) =>
      merge(this, isFetching: isFetching);
}

extension FutureValueStateExtension<T> on Future<T> {
  /// Generate a stream of [Value] during a processing [Future].
  Stream<Value<T>> toValues({bool guarded = true}) => Value<T>.initial().fetch(
        () => this,
        guarded: guarded,
      );
}
