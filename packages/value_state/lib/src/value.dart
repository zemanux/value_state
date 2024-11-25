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

/// A convinient class to handle different states of a value.
/// The three states are enumerated in [ValueState].
///
/// [T] cannot be `null`. If you need a nullable value, use an `Optinal` class
/// pattern as type.
final class Value<T extends Object> with _PrettyPrintMixin {
  /// Create a value in the initial state.
  const Value.initial({bool isFetching = false})
      : this._(
          data: null,
          failure: null,
          isFetching: isFetching,
        );

  /// Create a value in the success state with [data].
  const Value.success(T data, {bool isFetching = false})
      : this._(
          data: data,
          failure: null,
          isFetching: isFetching,
        );

  /// Map a value to `failure` with actual [data] if any and keep
  /// [Value.isFetching] if [isFetching] is null.
  Value<T> toFailure(
    Object error, {
    StackTrace? stackTrace,
    bool isFetching = false,
  }) =>
      Value._(
        data: data,
        failure: _Failure(error, stackTrace: stackTrace),
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
    required this.data,
    required _Failure? failure,
  }) : _failure = failure;

  /// A new value state will be available. It can start fron
  /// [ValueState.initial] or a previous [ValueState.success] or
  /// [ValueState.failure].
  final bool isFetching;

  /// Get data if available, otherwise return null.
  final T? data;

  final _Failure? _failure;

  /// Get error if available, otherwise return null.
  Object? get error => _failure?.error;

  /// Get stackTrace if available, otherwise return null.
  StackTrace? get stackTrace => _failure?.stackTrace;

  /// Get state of the value.
  ValueState get state {
    if (_failure != null) {
      return ValueState.failure;
    } else if (data != null) {
      return ValueState.success;
    } else {
      return ValueState.initial;
    }
  }

  /// Check if the value is in the initial state.
  bool get isInitial => state == ValueState.initial;

  /// Check if the value is in the success state.
  /// If the generic type T is nullable, isScuccess will return true if the
  /// data is null.
  bool get isSuccess => state == ValueState.success;

  /// Check if the value is in the failure state.
  bool get isFailure => state == ValueState.failure;

  /// Check if the value has data. It is a bit different of [isSuccess] because
  /// [ValueState.failure] can have data (from previous state).
  bool get hasData => data != null;

  /// Check if the value has error (available only in
  /// [ValueState.failure]).
  bool get hasError => _failure != null;

  /// Check if the value has stack trace (available only in
  /// [ValueState.failure]).
  bool get hasStackTrace => _failure?.stackTrace != null;

  /// Check if the value is refreshing : the current state is fetching with
  /// a previous fetch state ([ValueState.success] or [ValueState.failure]).
  bool get isRefreshing => !isInitial && isFetching;

  /// Copy the actual object with fetching as [isFetching].
  Value<T> copyWithFetching(bool isFetching) => Value._(
        data: data,
        failure: _failure,
        isFetching: isFetching,
      );

  /// Merge two values with different type. It is intendend to facilitate
  /// mapping of a data from a value to another without handling [Value.state],
  /// [Value.isFetching] and [Value.error]/[Value.stackTrace].
  Value<T> merge<F extends Object>(
    Value<F> from, {
    T Function(Value<F> from)? mapData,
  }) =>
      Value<T>._(
        data: mapData != null ? mapData(from) : this.data,
        failure: from._failure,
        isFetching: from.isFetching,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is Value<T> &&
          isFetching == other.isFetching &&
          data == other.data &&
          _failure == other._failure;

  @override
  int get hashCode => Object.hash(data, _failure, isFetching);

  @override
  Map<String, dynamic> get _attributes => {
        'state': state,
        'isFetching': isFetching,
        if (data != null) 'data': data,
        ...?_failure?._attributes,
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
