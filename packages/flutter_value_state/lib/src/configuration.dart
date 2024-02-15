import 'package:flutter/widgets.dart';
import 'package:value_state/value_state.dart';

Widget _defaultBuilder<T>(BuildContext context, Value<T> state) =>
    const SizedBox.shrink();

Widget _defaultWrapper<T>(BuildContext context, Value<T> state, Widget child) =>
    child;

typedef OnValueStateWaiting<T> = Widget Function(
    BuildContext context, Value<T> state);

typedef OnValueStateWithValue<T> = Widget Function(
    BuildContext context, Value<T> state, Widget? error);
typedef OnValueStateError<T> = Widget Function(
    BuildContext context, Value<T> state);
typedef OnValueStateDefault<T> = Widget Function(
    BuildContext context, Value<T> state);
typedef OnValueStateWrapper<T> = Widget Function(
    BuildContext context, Value<T> state, Widget child);

/// Define default behavior for the states init, success and error.
/// [builderDefault] can be used when none of this callback is mentionned.
class ValueBuilderConfigurationData {
  const ValueBuilderConfigurationData({
    OnValueStateWrapper? wrapper,
    OnValueStateWaiting? initial,
    OnValueStateError? failure,
    OnValueStateDefault? builderDefault,
  })  : _wrapper = wrapper,
        _builderWaiting = initial,
        _builderError = failure,
        _builderDefault = builderDefault;

  /// Builder for all states that will be wrapped by this builder.
  OnValueStateWrapper get wrapper => _wrapper ?? _defaultWrapper;
  final OnValueStateWrapper? _wrapper;

  /// Builder for [Value].
  OnValueStateWaiting get builderWaiting => _builderWaiting ?? builderDefault;
  final OnValueStateWaiting? _builderWaiting;

  /// Builder for [ErrorState].
  OnValueStateError get builderError => _builderError ?? builderDefault;
  final OnValueStateError? _builderError;

  /// Fallback builder when one of the state builder is empty.
  OnValueStateDefault get builderDefault => _builderDefault ?? _defaultBuilder;
  final OnValueStateDefault? _builderDefault;

  /// Creates a copy of this [ValueBuilderConfigurationData] but with the given
  /// fields replaced with the new values.
  ValueBuilderConfigurationData copyWith({
    OnValueStateWrapper? wrapper,
    OnValueStateWaiting? builderWaiting,
    OnValueStateError? builderError,
    OnValueStateDefault? builderDefault,
  }) =>
      ValueBuilderConfigurationData(
        wrapper: wrapper ?? this.wrapper,
        initial: builderWaiting ?? this.builderWaiting,
        failure: builderError ?? this.builderError,
        builderDefault: builderDefault ?? this.builderDefault,
      );

  /// Creates a new [ValueBuilderConfigurationData] where each parameter
  /// from this object has been merged with the matching attribute.
  ValueBuilderConfigurationData merge(
      ValueBuilderConfigurationData? configuration) {
    final baseConfiguration =
        configuration ?? const ValueBuilderConfigurationData();

    return baseConfiguration.copyWith(
      wrapper: _wrapper,
      builderWaiting: _builderWaiting,
      builderError: _builderError,
      builderDefault: _builderDefault,
    );
  }

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ValueBuilderConfigurationData &&
          wrapper == other.wrapper &&
          builderWaiting == other.builderWaiting &&
          builderError == other.builderError &&
          builderDefault == other.builderDefault;

  @override
  int get hashCode => Object.hash(
        wrapper,
        builderWaiting,
        builderError,
        builderDefault,
      );
}

/// Provide a [ValueBuilderConfigurationData] for all inherited widget to define
/// default behavior for any state of [Value] except [ValueState].
///
/// If this configuration is in a subtree of another [ValueBuilderConfiguration],
/// the configuration will be merged with the parent one.
class ValueBuilderConfiguration extends StatelessWidget {
  const ValueBuilderConfiguration({
    super.key,
    required this.configuration,
    required this.child,
  });

  /// The default to configuration.
  final ValueBuilderConfigurationData configuration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inheritedConfiguration = maybeOf(context);

    return _ValueStateConfiguration(
        configuration: configuration.merge(inheritedConfiguration),
        child: child);
  }

  static ValueBuilderConfigurationData? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ValueStateConfiguration>()
      ?.configuration;

  static ValueBuilderConfigurationData of(BuildContext context) {
    final ValueBuilderConfigurationData? configuration = maybeOf(context);

    assert(configuration != null,
        'No $ValueBuilderConfiguration found in context');

    return configuration!;
  }
}

class _ValueStateConfiguration extends InheritedWidget {
  const _ValueStateConfiguration(
      {required this.configuration, required super.child});

  final ValueBuilderConfigurationData configuration;

  @override
  bool updateShouldNotify(covariant _ValueStateConfiguration oldWidget) =>
      configuration != oldWidget.configuration;
}
