import 'package:flutter/widgets.dart';
import 'package:value_state/value_state.dart';

typedef OnValueStateWaiting<T> = Widget Function(
    BuildContext context, WaitingState<T> state);

typedef OnValueStateWithValue<T> = Widget Function(
    BuildContext context, WithValueState<T> state);
typedef OnValueStateNoValue<T> = Widget Function(
    BuildContext context, NoValueState<T> state);
typedef OnValueStateError<T> = Widget Function(
    BuildContext context, ErrorState<T> state);
typedef OnValueStateDefault<T> = Widget Function(
    BuildContext context, BaseState<T> state);
typedef OnValueStateWrapperForTheme<T> = Widget Function(
    BuildContext context, BaseState<T> state, Widget child);

class ValueStateConfigurationData {
  const ValueStateConfigurationData(
      {this.onWaiting, this.onNoValue, this.onError, this.onDefault});

  final OnValueStateWaiting? onWaiting;

  final OnValueStateNoValue? onNoValue;
  final OnValueStateError? onError;

  final OnValueStateDefault? onDefault;

  ValueStateConfigurationData copyWith({
    OnValueStateWaiting? onWaiting,
    OnValueStateNoValue? onNoValue,
    OnValueStateError? onError,
    OnValueStateDefault? onDefault,
  }) =>
      ValueStateConfigurationData(
        onWaiting: onWaiting ?? this.onWaiting,
        onNoValue: onNoValue ?? this.onNoValue,
        onError: onError ?? this.onError,
        onDefault: onDefault ?? this.onDefault,
      );

  ValueStateConfigurationData merge(ValueStateConfigurationData? theme) {
    final baseTheme = theme ?? const ValueStateConfigurationData();

    return baseTheme.copyWith(
      onWaiting: onWaiting,
      onNoValue: onNoValue,
      onError: onError,
      onDefault: onDefault,
    );
  }

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ValueStateConfigurationData &&
          onWaiting == other.onWaiting &&
          onNoValue == other.onNoValue &&
          onError == other.onError &&
          onDefault == other.onDefault;

  @override
  int get hashCode => Object.hash(onNoValue, onWaiting, onError, onDefault);
}
