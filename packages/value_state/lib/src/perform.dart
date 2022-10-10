import 'dart:async';

import '../value_state.dart';

typedef PerfomOnStateEmitter<T> = FutureOr<void> Function(BaseState<T> state);
typedef PerfomOnStateAction<T, R> = FutureOr<R> Function(
    BaseState<T> state, PerfomOnStateEmitter<T> emitter);

Future<R> performOnState<T, R>(
    {required BaseState<T> Function() state,
    required PerfomOnStateEmitter<T> emitter,
    required PerfomOnStateAction<T, R> action,
    bool errorAsState = true}) async {
  try {
    final currentState = state();
    final stateRefreshing = currentState.mayRefreshing();

    if (currentState != stateRefreshing) await emitter(stateRefreshing);

    return await action(state(), emitter);
  } catch (error, stackTrace) {
    if (errorAsState) {
      await emitter(ErrorState<T>(
          previousState: state().mayNotRefreshing(),
          error: error,
          stackTrace: stackTrace));
    }
    rethrow;
  } finally {
    final currentState = state();
    final stateRefreshingEnd = currentState.mayNotRefreshing();

    if (currentState != stateRefreshingEnd) await emitter(stateRefreshingEnd);
  }
}
