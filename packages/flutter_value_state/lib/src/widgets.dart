import 'package:flutter/widgets.dart';
import 'package:value_state/value_state.dart';

import 'configuration.dart';

final _stateOnErrorExpando =
    Expando<OnValueStateError>('ValueState.buildError');

Widget _onDefault<T>(BuildContext context, BaseState<T> state) =>
    const SizedBox.shrink();

extension StateConfigurationExtensions on BuildContext {
  ValueStateConfigurationData get stateTheme =>
      ValueStateConfiguration.of(this);
}

extension ValueStateBuilderExtension<T> on BaseState<T> {
  Widget buildWidget(
    OnValueStateWithValue<T> onWithValue, {
    Key? key,
    OnValueStateWaiting<T>? onWaiting,
    OnValueStateNoValue<T>? onNoValue,
    OnValueStateError<T>? onError,
    OnValueStateDefault<T>? onDefault,
    OnValueStateWrapperForTheme<T>? wrapper,
    bool valueMixedWithError = false,
  }) =>
      accept(_ValueStateBuilderVisitor<T>(
        onDefault: onDefault,
        onError: onError,
        onWithValue: onWithValue,
        onNoValue: onNoValue,
        onWaiting: onWaiting,
        valueMixedWithError: valueMixedWithError,
        wrapper: wrapper,
      ));

  Widget buildError() => Builder(
        builder: (context) {
          final state = this;
          final onDefault =
              ValueStateConfiguration.maybeOf(context)?.onDefault ?? _onDefault;

          if (state is! ErrorState<T>) return onDefault(context, state);
          final onError = _stateOnErrorExpando[state];

          if (onError == null) return onDefault(context, state);

          return onError(context, state);
        },
      );
}

class _ValueStateBuilderVisitor<T> extends StateVisitor<Widget, T> {
  const _ValueStateBuilderVisitor({
    required this.onWithValue,
    required this.onWaiting,
    required this.onNoValue,
    required this.onError,
    required this.onDefault,
    required this.wrapper,
    required this.valueMixedWithError,
  });

  final OnValueStateWithValue<T> onWithValue;

  final OnValueStateWaiting<T>? onWaiting;

  final OnValueStateNoValue<T>? onNoValue;
  final OnValueStateError<T>? onError;
  final OnValueStateDefault<T>? onDefault;
  final OnValueStateWrapperForTheme<T>? wrapper;

  final bool valueMixedWithError;

  Widget _builder(
    BaseState<T> state,
    Widget? Function(BuildContext context,
            ValueStateConfigurationData? valueStateConfiguration)
        builder,
  ) =>
      _StateBuilder(
          state: state,
          builder: builder,
          onDefault: onDefault,
          wrapper: wrapper);

  @override
  Widget visitInitState(InitState<T> state) => _visitWaitingState(state);

  @override
  Widget visitPendingState(PendingState<T> state) => _visitWaitingState(state);

  Widget _visitWaitingState(WaitingState<T> state) =>
      _builder(state, (context, valueStateConfiguration) {
        final onWaiting = this.onWaiting ?? valueStateConfiguration?.onWaiting;

        return onWaiting?.call(context, state);
      });

  @override
  Widget visitNoValueState(NoValueState<T> state) =>
      _builder(state, (context, valueStateConfiguration) {
        final onNoValue = this.onNoValue ?? valueStateConfiguration?.onNoValue;

        return onNoValue?.call(context, state);
      });

  @override
  Widget visitValueState(ValueState<T> state) => _visitWithValueState(state);

  @override
  Widget visitErrorState(ErrorState<T> state) {
    if (valueMixedWithError && state is ErrorWithPreviousValue<T>) {
      return _visitWithValueState(state);
    }

    return _builder(state, (context, valueStateConfiguration) {
      final onError = this.onError ?? valueStateConfiguration?.onError;

      return onError?.call(context, state);
    });
  }

  Widget _visitWithValueState(WithValueState<T> state) =>
      _builder(state, (context, valueStateConfiguration) {
        final onError = this.onError ?? valueStateConfiguration?.onError;
        if (onError != null) {
          _stateOnErrorExpando[state] = onError as OnValueStateError<dynamic>;
        }

        return onWithValue(context, state);
      });
}

class _StateBuilder<T> extends StatelessWidget {
  const _StateBuilder({
    required this.state,
    required this.builder,
    required this.onDefault,
    required this.wrapper,
  });

  final BaseState<T> state;
  final Widget? Function(BuildContext context,
      ValueStateConfigurationData? valueStateConfiguration) builder;
  final OnValueStateDefault<T>? onDefault;
  final OnValueStateWrapperForTheme<T>? wrapper;

  @override
  Widget build(BuildContext context) {
    final valueStateConfiguration = ValueStateConfiguration.maybeOf(context);
    Widget? child = builder(context, valueStateConfiguration);

    if (child == null) {
      final localOnDefault =
          onDefault ?? valueStateConfiguration?.onDefault ?? _onDefault<T>;
      child = localOnDefault(context, state);
    }

    final wrapBuilder = wrapper ??
        (BuildContext context, BaseState<T> state, Widget child) => child;

    return wrapBuilder(context, state, child);
  }
}
