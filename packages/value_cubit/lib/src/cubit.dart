import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';
import 'package:value_state/value_state.dart';

/// Shortbut to user [BaseState] with [Cubit]
abstract class ValueCubit<T> extends Cubit<BaseState<T>>
    with CubitValueStateMixin {
  ValueCubit([BaseState<T>? initState]) : super(initState ?? InitState<T>());
}

/// Shared implementation to handle refresh capability on cubit
abstract class RefreshValueCubit<T> extends ValueCubit<T>
    with CubitValueStateMixin {
  RefreshValueCubit([BaseState<T>? initState])
      : super(initState ?? InitState<T>());

  /// Refresh the cubit state.
  Future<void> refresh() async {
    await perform(emitValues);
  }

  /// Init the state of cubit.
  void clear() {
    emit(PendingState<T>());
  }

  /// Get the value here and emit a [ValueState] if success.
  @protected
  Future<void> emitValues();
}

mixin CubitValueStateMixin<T> on Cubit<BaseState<T>> {
  final _lock = Lock(reentrant: true);

  /// Handle states (waiting, refreshing, error...) while an [action] is
  /// processed.
  /// If [errorAsState] is `true` and [action] raise an exception then an
  /// [ErrorState] is emitted. if `false`, nothing is emitted. The exception
  /// is always rethrown by [perform] to be handled by the caller.
  @protected
  Future<R> perform<R>(FutureOr<R> Function() action,
          {bool errorAsState = true}) =>
      _lock.synchronized(
        () => performOnState<T, R>(
            state: () => state,
            emitter: emit,
            action: (state, emitter) => action()),
      );
}

/// Execute [CubitValueStateMixin.perform] on each cubit of a list.
/// Useful for cubits that are suscribed to others.
@Deprecated('This feature will be dropped in 2.0')
Future<R> performOnIterable<R>(
    Iterable<ValueCubit> cubits, FutureOr<R> Function() action,
    {bool errorAsState = true}) async {
  if (cubits.isEmpty) {
    return await action();
  }

  return performOnIterable<R>(cubits.skip(1),
      () => cubits.first.perform<R>(action, errorAsState: errorAsState),
      errorAsState: errorAsState);
}
