import 'package:flutter/widgets.dart';
import 'package:value_state/value_state.dart';

import 'configuration.dart';

extension StateConfigurationExtensions on BuildContext {
  ValueBuilderConfigurationData get stateConfiguration =>
      ValueBuilderConfiguration.maybeOf(this) ??
      const ValueBuilderConfigurationData();
}

extension ValueStateBuilderExtension<T extends Object> on Value<T> {
  Widget buildWidget({
    Key? key,
    OnValueStateWithValue<T>? onValue,
    OnValueStateWaiting<T>? onWaiting,
    OnValueStateError<T>? onError,
    OnValueStateDefault<T>? onDefault,
    OnValueStateWrapper<T>? wrapper,
    bool wrapped = true,
    bool valueMixedWithError = false,
  }) =>
      ValueStateWidget<T>(
        state: this,
        onDefault: onDefault,
        onError: onError,
        onWithValue: onValue,
        onWaiting: onWaiting,
        valueMixedWithError: valueMixedWithError,
        wrapped: wrapped,
        wrapper: wrapper,
      );
}

class ValueStateWidget<T extends Object> extends StatelessWidget {
  const ValueStateWidget({
    required this.state,
    this.onWithValue,
    this.onWaiting,
    this.onError,
    this.onDefault,
    this.wrapper,
    this.wrapped = true,
    this.valueMixedWithError = false,
  });

  final Value<T> state;

  final OnValueStateWithValue<T>? onWithValue;

  final OnValueStateWaiting<T>? onWaiting;

  final OnValueStateError<T>? onError;
  final OnValueStateDefault<T>? onDefault;
  final OnValueStateWrapper<T>? wrapper;

  final bool wrapped;
  final bool valueMixedWithError;

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    if (state.isInitial) {
      return _buildInitState(context, state);
    } else if (state.isSuccess) {
      return _buildSuccess(context, state);
    } else if (state.isFailure) {
      return _buildError(context, state);
    }

    // coverage:ignore-start
    throw UnimplementedError();
    // coverage:ignore-end
  }

  Widget _builder(
    BuildContext context,
    Value<T> state,
    Widget Function(
      BuildContext context,
      ValueBuilderConfigurationData valueStateConfiguration,
      OnValueStateDefault<T>? onDefault,
    ) builder,
  ) {
    final valueStateConfiguration = context.stateConfiguration;
    Widget child = builder(context, valueStateConfiguration, onDefault);

    if (wrapper != null) {
      child = wrapper!(context, state, child);
    }

    return wrapped
        ? valueStateConfiguration.wrapper(context, state, child)
        : child;
  }

  Widget _buildInitState(BuildContext context, Value<T> state) =>
      _builder(context, state, (context, valueStateConfiguration, onDefault) {
        final onWaiting = this.onWaiting ??
            onDefault ??
            valueStateConfiguration.builderWaiting;

        return onWaiting(context, state);
      });

  Widget _buildSuccess(BuildContext context, Value<T> state) =>
      _builder(context, state, (context, valueStateConfiguration, onDefault) {
        final onError =
            this.onError ?? onDefault ?? valueStateConfiguration.builderError;
        Widget? error;

        if (state.hasData) {
          error = onError(context, state);
        }

        return onWithValue?.call(context, state, error) ??
            onDefault?.call(context, state) ??
            valueStateConfiguration.builderDefault(context, state);
      });

  Widget _buildError(BuildContext context, Value<T> state) {
    if (valueMixedWithError && state.hasData) {
      return _buildSuccess(context, state);
    }

    return _builder(context, state,
        (context, valueStateConfiguration, onDefault) {
      final onError =
          this.onError ?? onDefault ?? valueStateConfiguration.builderError;

      return onError(context, state);
    });
  }
}
