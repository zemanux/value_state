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
      _ValueStateBuilder<T>(
        state: this,
        onWithValue: onWithValue,
        onWaiting: onWaiting,
        onNoValue: onNoValue,
        onError: onError,
        onDefault: onDefault,
        wrapper: wrapper,
        valueMixedWithError: valueMixedWithError,
      );

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

class ValueStateConfiguration extends StatelessWidget {
  const ValueStateConfiguration(
      {super.key, required this.theme, required this.child});

  final ValueStateConfigurationData theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final themeInherited = maybeOf(context);

    return _ValueStateConfiguration(
        theme: theme.merge(themeInherited), child: child);
  }

  static ValueStateConfigurationData? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ValueStateConfiguration>()
      ?.theme;

  static ValueStateConfigurationData of(BuildContext context) {
    final ValueStateConfigurationData? configuration = maybeOf(context);

    assert(configuration != null, 'No ValueStateTheme found in context');

    return configuration!;
  }
}

class _ValueStateConfiguration extends InheritedWidget {
  const _ValueStateConfiguration({required this.theme, required super.child});

  final ValueStateConfigurationData theme;

  @override
  bool updateShouldNotify(covariant _ValueStateConfiguration oldWidget) =>
      theme != oldWidget.theme;
}

class _ValueStateBuilder<T> extends StatelessWidget {
  const _ValueStateBuilder({
    required this.state,
    required this.onWithValue,
    required this.onWaiting,
    required this.onNoValue,
    required this.onError,
    required this.onDefault,
    required this.wrapper,
    required this.valueMixedWithError,
  });

  final BaseState<T> state;

  final OnValueStateWithValue<T> onWithValue;

  final OnValueStateWaiting<T>? onWaiting;

  final OnValueStateNoValue<T>? onNoValue;
  final OnValueStateError<T>? onError;
  final OnValueStateDefault<T>? onDefault;
  final OnValueStateWrapperForTheme<T>? wrapper;

  final bool valueMixedWithError;

  @override
  Widget build(BuildContext context) {
    final localState = state;

    final builder = wrapper ?? _defaultWrapper;
    final valueStateTheme = ValueStateConfiguration.maybeOf(context);
    final onDefault =
        this.onDefault ?? valueStateTheme?.onDefault ?? _onDefault<T>;

    final onError = this.onError ?? valueStateTheme?.onError;

    Widget? child;
    if (localState is WaitingState<T>) {
      final onWaiting = this.onWaiting ?? valueStateTheme?.onWaiting;

      if (onWaiting != null) {
        child = onWaiting(context, localState);
      }
    } else if (!valueMixedWithError && localState is ErrorState<T>) {
      if (onError != null) {
        child = onError(context, localState);
      }
    } else if (localState is WithValueState<T>) {
      _stateOnErrorExpando[state] = onError as OnValueStateError<dynamic>?;

      child = onWithValue(context, localState);
    } else if (localState is NoValueState<T>) {
      final onNoValue = this.onNoValue ?? valueStateTheme?.onNoValue;

      if (onNoValue != null) {
        child = onNoValue(context, localState);
      }
    } else if (localState is ErrorState<T>) {
      if (onError != null) {
        child = onError(context, localState);
      }
    }
    child ??= onDefault(context, localState);

    return builder(context, localState, child);
  }

  Widget _defaultWrapper(
          BuildContext context, BaseState<T> state, Widget child) =>
      child;
}
