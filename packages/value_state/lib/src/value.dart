library value_state;

import 'package:meta/meta.dart';

/// A class that represents a value that can be in one of three states:
/// * [ValueState.initial] - the initial state of the value.
/// * [ValueState.success] - the state when the value is successfully fetched.
/// * [ValueState.failure] - the state when the value is failed to fetch.
enum ValueState {
  initial,
  success,
  failure,
}

class ValueDataNotAvailableException implements Exception {
  const ValueDataNotAvailableException();

  @override
  String toString() => 'Exception: Data is not available on value';
}

/// A convinient class to handle different states of a value.
/// The three states are enumerated in [ValueState].
final class Value<T> with _PrettyPrintMixin {
  /// Create a value in the initial state.
  const Value.initial({bool isFetching = false})
      : this._(
          data: null,
          failure: null,
          isFetching: isFetching,
        );

  /// Map a value to value with [data] and keep [Value.isFetching] if
  /// [isFetching] is `null`.
  Value<T> toSuccess(T data, {bool? isFetching}) => merge(
        Value.success(data, isFetching: false),
        mapData: (from) => data,
        isFetching: isFetching,
      );

  /// Map a value to failure with actual [data] if any and [Value.isFetching]
  /// if [isFetching] is null.
  Value<T> toFailure(
    Object error, {
    StackTrace? stackTrace,
    bool? isFetching,
  }) =>
      merge(
        Value.failure(error, stackTrace: stackTrace, isFetching: false),
        isFetching: isFetching,
      );

  /// Create a value in the success state.
  /// This is only for tests purpose.
  @visibleForTesting
  Value.success(T data, {bool isFetching = false})
      : this._(
          data: _Data(data),
          failure: null,
          isFetching: isFetching,
        );

  /// Create a value in the failure state.
  /// This is only for tests purpose.
  @visibleForTesting
  Value.failure(
    Object error, {
    StackTrace? stackTrace,
    bool isFetching = false,
  }) : this._(
          data: null,
          failure: _Failure(error, stackTrace: stackTrace),
          isFetching: isFetching,
        );

  const Value._({
    required this.isFetching,
    required _Data<T>? data,
    required _Failure? failure,
  })  : _data = data,
        _failure = failure;

  /// A new value state will be available. It can start fron
  /// [ValueState.initial] or a previous [ValueState.success] or
  /// [ValueState.failure].
  final bool isFetching;
  final _Data<T>? _data;
  final _Failure? _failure;

  /// Get data if available, otherwise return null.
  T? get data => _data?.data;

  /// Get data or throw an exception if data is not available.
  /// It is useful when [T] is nullable.
  T get dataOrThrow => switch (_data) {
        _Data<T>(:final data) => data,
        null => throw const ValueDataNotAvailableException(),
      };

  /// Get error if available, otherwise return null.
  Object? get error => _failure?.error;

  /// Get stackTrace if available, otherwise return null.
  StackTrace? get stackTrace => _failure?.stackTrace;

  /// Get state of the value.
  ValueState get state {
    if (_failure != null) {
      return ValueState.failure;
    } else if (_data != null) {
      return ValueState.success;
    } else {
      return ValueState.initial;
    }
  }

  /// Check if the value is in the initial state.
  bool get isInitial => state == ValueState.initial;

  /// Check if value has already been fetched (success or failure).
  bool get hasBeenFetched => !isInitial;

  /// Check if the value is in the success state.
  /// If the generic type T is nullable, isScuccess will return true if the
  /// data is null.
  bool get isSuccess => state == ValueState.success;

  /// Check if the value is in the failure state.
  bool get isFailure => state == ValueState.failure;

  /// Check if the value has data. It is a bit different of [hasBeenFetched] and
  /// [isSuccess].
  /// If [T] is nullable and fetched [data] is null, it returns false. If you
  /// want to verify if data is available (fetched), use [hasBeenFetched].
  /// [ValueState.failure] can have data (from previous state).
  bool get hasData => _data != null;

  /// Check if the value has error (available only in
  /// [ValueState.failure]).
  bool get hasError => _failure != null;

  /// Check if the value has stack trace (available only in
  /// [ValueState.failure]).
  bool get hasStackTrace => _failure?.stackTrace != null;

  /// Check if the value is refreshing : the current state is fetching with
  /// a previous fetch state ([ValueState.success] or [ValueState.failure]).
  bool get isRefreshing => !isInitial && isFetching;

  /// Merge two values with different type. It is intendend to facilitate
  /// mapping of a data from a value to another without handling [state],
  /// [isFetching] and [error]/[stackTrace].
  Value<T> merge<F>(
    Value<F> from, {
    T Function(Value<F> from)? mapData,
    bool? isFetching,
  }) =>
      Value<T>._(
        data: mapData != null ? _Data(mapData(from)) : this._data,
        failure: from._failure,
        isFetching: isFetching ?? from.isFetching,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is Value<T> &&
          isFetching == other.isFetching &&
          _data == other._data &&
          _failure == other._failure;

  @override
  int get hashCode => Object.hash(_data, _failure, isFetching);

  @override
  Map<String, dynamic> get _attributes => {
        'state': state,
        'isFetching': isFetching,
        ...?_data?._attributes,
        ...?_failure?._attributes,
      };
}

/// This class wraps a data object of type [T]. It provides a mechanism to:
///  * Handle nullable types safely.
///  * Distinguish between a null value due to initialization
///    ([ValueState.initial]) and a null value assigned after initialization.
final class _Data<T> with _PrettyPrintMixin {
  const _Data(this.data);

  final T data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is _Data<T> &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  Map<String, dynamic> get _attributes => {
        'data': data,
      };
}

final class _Failure with _PrettyPrintMixin {
  const _Failure(this.error, {this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is _Failure &&
          error == other.error &&
          stackTrace == other.stackTrace;

  @override
  int get hashCode => Object.hash(error, stackTrace);

  @override
  Map<String, dynamic> get _attributes => {
        'error': error,
        'stackTrace': stackTrace,
      };
}

mixin _PrettyPrintMixin {
  Map<String, dynamic> get _attributes;

  @override
  String toString() {
    return '$runtimeType($prettyPrint)';
  }

  String get prettyPrint => _attributes.entries
      .where(
          (entry) => entry.value != null && entry.value.toString().isNotEmpty)
      .map((entry) => '${entry.key}: ${entry.value}')
      .join(', ');
}
