enum ValueState {
  initial,
  success,
  failure,
}

final class Value<T> with _PrettyPrintMixin {
  const Value.initial({this.isFetching = false})
      : _data = null,
        _failure = null;

  Value.success(T data, {this.isFetching = false})
      : _data = _Data<T>(data),
        _failure = null;

  Value.failure(
    Object error, {
    StackTrace? stackTrace,
    this.isFetching = false,
  })  : _data = null,
        _failure = _Failure(error, stackTrace: stackTrace);

  const Value._({
    required this.isFetching,
    required _Data<T>? data,
    required _Failure? failure,
  })  : _data = data,
        _failure = failure;

  final bool isFetching;
  final _Data<T>? _data;
  final _Failure? _failure;

  T get data {
    if (_data == null) {
      throw StateError('Value is not in a success state');
    }

    return _data.data;
  }

  Object get error {
    if (_failure == null) {
      throw StateError('Value is not in a failure state');
    }

    return _failure.error;
  }

  StackTrace? get stackTrace {
    if (_failure == null) {
      throw StateError('Value is not in a failure state');
    }

    return _failure.stackTrace;
  }

  ValueState get state {
    if (_failure != null) {
      return ValueState.failure;
    } else if (_data != null) {
      return ValueState.success;
    } else {
      return ValueState.initial;
    }
  }

  bool get isInitial => state == ValueState.initial;
  bool get isSuccess => state == ValueState.success;
  bool get isFailure => state == ValueState.failure;

  bool get hasData => _data != null;
  bool get hasError => _failure != null;
  bool get hasStackTrace => _failure?.stackTrace != null;

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
