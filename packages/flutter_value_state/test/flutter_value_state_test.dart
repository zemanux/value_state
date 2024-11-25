import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_value_state/flutter_value_state.dart';

const _buildWidgetKey = ValueKey('buildWidget');
const _defaultWidgetKey = ValueKey('defaultWidget');
const _errorWidgetKey = ValueKey('errorWidget');
const _noValueWidgetKey = ValueKey('noValueWidget');
const _waitingWidgetKey = ValueKey('waitingWidget');
const _wrapperWidgetKey = ValueKey('wrapperWidget');
const _defaultWidgetType = SizedBox;

late ValueBuilderConfigurationData _valueStateConfigurationData;

class _TestWidget<T extends Value<int>> extends StatelessWidget {
  const _TestWidget({
    required this.state,
    this.valueMixedWithError = false,
    this.child,
    this.onWaiting,
    this.onError,
    this.onDefault,
    this.wrapper,
    this.wrapped = true,
    this.onValueEnabled = true,
  });

  final T state;
  final bool valueMixedWithError;

  final Widget? child;

  final OnValueStateWaiting<Object>? onWaiting;
  final OnValueStateError<Object>? onError;
  final OnValueStateDefault<Object>? onDefault;
  final OnValueStateWrapper<Object>? wrapper;

  final bool wrapped;
  final bool onValueEnabled;

  @override
  Widget build(BuildContext context) {
    return state.buildWidget(
      onValue: onValueEnabled
          ? (context, state, error) {
              return Column(
                children: [
                  if (error != null) error,
                  child ?? const SizedBox.shrink(key: _buildWidgetKey),
                ],
              );
            }
          : null,
      valueMixedWithError: valueMixedWithError,
      onDefault: onDefault,
      onError: onError,
      onWaiting: onWaiting,
      wrapper: wrapper,
      wrapped: wrapped,
    );
  }
}

class _TestConfigurationWidget<T extends Value<int>> extends StatefulWidget {
  const _TestConfigurationWidget({
    super.key,
    required this.state,
    this.valueMixedWithError = false,
    this.child,
    this.onWaiting,
    this.onError,
    this.onDefault,
    this.wrapper,
    this.wrapped = true,
    this.onValueEnabled = true,
  });

  final T state;
  final bool valueMixedWithError;

  final Widget? child;

  final OnValueStateWaiting<Object>? onWaiting;
  final OnValueStateError<Object>? onError;
  final OnValueStateDefault<Object>? onDefault;
  final OnValueStateWrapper<Object>? wrapper;

  final bool wrapped;
  final bool onValueEnabled;

  @override
  State<_TestConfigurationWidget<T>> createState() =>
      _TestConfigurationWidgetState<T>();
}

class _TestConfigurationWidgetState<T extends Value<int>>
    extends State<_TestConfigurationWidget<T>> {
  OnValueStateError _onError =
      (context, state) => const SizedBox.shrink(key: _errorWidgetKey);

  void updateOnError(OnValueStateError onError) {
    setState(() {
      _onError = onError;
    });
  }

  @override
  Widget build(BuildContext context) {
    _valueStateConfigurationData = ValueBuilderConfigurationData(
      builderDefault: (context, state) =>
          const SizedBox.shrink(key: _defaultWidgetKey),
      failure: _onError,
      initial: (context, state) =>
          const SizedBox.shrink(key: _waitingWidgetKey),
      wrapper: (context, state, child) =>
          KeyedSubtree(key: _wrapperWidgetKey, child: child),
    );

    return ValueBuilderConfiguration(
        configuration: _valueStateConfigurationData,
        child: _TestWidget<T>(
          state: widget.state,
          valueMixedWithError: widget.valueMixedWithError,
          child: widget.child,
          onDefault: widget.onDefault,
          onError: widget.onError,
          onWaiting: widget.onWaiting,
          wrapper: widget.wrapper,
          wrapped: widget.wrapped,
          onValueEnabled: widget.onValueEnabled,
        ));
  }
}

void main() {
  test('$ValueBuilderConfiguration.copyWith without parameter', () {
    const configuration = ValueBuilderConfigurationData();

    expect(configuration.copyWith(), configuration);
  });

  group('without configuration', () {
    testWidgets('buildWidget with ${Value<int>}', (tester) async {
      await tester.pumpWidget(const _TestWidget(state: Value.success(1)));

      expect(find.byKey(_buildWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsOneWidget);
    });

    testWidgets('buildWidget without parameter with ${Value<int>}',
        (tester) async {
      await tester.pumpWidget(const Value.success(1).buildWidget());

      expect(find.byKey(_buildWidgetKey), findsNothing);
      expect(find.byType(_defaultWidgetType), findsOneWidget);
    });

    for (final state in <Value<int>>[
      const Value.initial(),
      const Value.initial(isFetching: true),
      const Value.success(1),
      Value.failure('Error', isFetching: false)
    ]) {
      testWidgets('defaultBuilder with ${state.runtimeType}', (tester) async {
        await tester.pumpWidget(_TestWidget(state: state));

        expect(find.byKey(_buildWidgetKey), findsNothing);
        expect(find.byType(_defaultWidgetType), findsOneWidget);
      });

      testWidgets(
          'defaultBuilder with empty configuration ${state.runtimeType}',
          (tester) async {
        await tester.pumpWidget(
          ValueBuilderConfiguration(
              configuration: const ValueBuilderConfigurationData(),
              child: _TestWidget(state: state)),
        );

        expect(find.byKey(_buildWidgetKey), findsNothing);
        expect(find.byType(_defaultWidgetType), findsOneWidget);
      });
    }

    for (final state in <Value<int>>[
      const Value.initial(),
      const Value.initial(isFetching: true),
      const Value.success(1),
      Value.failure('Error', isFetching: false)
    ]) {
      testWidgets('defaultBuilder with ${state.runtimeType}', (tester) async {
        await tester.pumpWidget(_TestWidget(state: state));

        expect(find.byKey(_buildWidgetKey), findsNothing);
        expect(find.byType(_defaultWidgetType), findsOneWidget);
      });
    }
  });

  group('with configuration', () {
    testWidgets('should get ValueStateConfigurationData', (tester) async {
      late ValueBuilderConfigurationData valueStateConfigurationData;
      await tester.pumpWidget(_TestConfigurationWidget(
          state: const Value.success(1),
          child: Builder(builder: (context) {
            valueStateConfigurationData = ValueBuilderConfiguration.of(context);
            return const SizedBox.shrink();
          })));

      expect(valueStateConfigurationData, _valueStateConfigurationData);
      expect(valueStateConfigurationData.hashCode,
          _valueStateConfigurationData.hashCode);
    });

    testWidgets('buildWidget with ${Value<int>}', (tester) async {
      final testKey = GlobalKey<_TestConfigurationWidgetState>();
      await tester.pumpWidget(_TestConfigurationWidget(
        key: testKey,
        state: const Value.success(1),
      ));

      expect(find.byKey(_buildWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsOneWidget);

      testKey.currentState!.updateOnError((context, state) {
        return Container(key: _errorWidgetKey);
      });

      expect(find.byKey(_buildWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsOneWidget);
    });

    for (final state in <Value<int>, Key>{
      const Value.initial(): _waitingWidgetKey,
      const Value.initial(isFetching: true): _waitingWidgetKey,
      const Value.success(1): _buildWidgetKey,
      Value.failure('Error', isFetching: false): _errorWidgetKey,
      const Value.success(0).toFailure('Error', isFetching: true):
          _errorWidgetKey,
    }.entries) {
      testWidgets('build with ${state.key.runtimeType}', (tester) async {
        await tester.pumpWidget(_TestConfigurationWidget(state: state.key));

        expect(find.byKey(state.value), findsOneWidget);
        expect(find.byType(_defaultWidgetType), findsOneWidget);
      });

      testWidgets('build with ${state.key.runtimeType} and onDefault',
          (tester) async {
        await tester.pumpWidget(_TestConfigurationWidget(
          state: state.key,
          onDefault: (context, state) => Container(key: _defaultWidgetKey),
          valueMixedWithError: true,
          onValueEnabled: false,
        ));

        expect(find.byKey(state.value), findsNothing);
        expect(find.byKey(_defaultWidgetKey), findsOneWidget);
      });
    }

    for (final state in <Value<int>, Key>{
      const Value.initial(): _waitingWidgetKey,
      const Value.initial(isFetching: true): _waitingWidgetKey,
      const Value.success(1): _noValueWidgetKey,
      Value.failure('Error', isFetching: false): _errorWidgetKey,
    }.entries) {
      const wrapperKey = Key('innerWrapperWidget');
      testWidgets(
          'build with ${state.key.runtimeType} and callbacks and wrapper',
          (tester) async {
        await tester.pumpWidget(_TestConfigurationWidget(
          state: state.key,
          onDefault: (context, state) => Container(key: _defaultWidgetKey),
          onError: (context, state) => Container(key: _errorWidgetKey),
          onWaiting: (context, state) => Container(key: _waitingWidgetKey),
          wrapper: (context, state, child) =>
              Center(key: wrapperKey, child: child),
        ));

        expect(find.byKey(state.value), findsOneWidget);
        expect(find.byKey(wrapperKey), findsOneWidget);
        expect(find.byKey(_defaultWidgetKey), findsNothing);
        expect(find.byType(_defaultWidgetType), findsNothing);
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Center), findsOneWidget);
      });

      testWidgets(
          'build with ${state.key.runtimeType} and callbacks and wrapper disabled',
          (tester) async {
        await tester.pumpWidget(_TestConfigurationWidget(
          state: state.key,
          onDefault: (context, state) => Container(key: _defaultWidgetKey),
          onError: (context, state) => Container(key: _errorWidgetKey),
          onWaiting: (context, state) => Container(key: _waitingWidgetKey),
          wrapper: (context, state, child) =>
              Center(key: wrapperKey, child: child),
          wrapped: false,
        ));

        expect(find.byKey(state.value), findsOneWidget);
        expect(find.byKey(wrapperKey), findsOneWidget);
        expect(find.byKey(_defaultWidgetKey), findsNothing);
        expect(find.byType(_defaultWidgetType), findsNothing);
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Center), findsOneWidget);
      });
    }

    testWidgets('build with ${Value<int>}.failure with and valueMixedWithError',
        (tester) async {
      final testKey = GlobalKey<_TestConfigurationWidgetState>();
      await tester.pumpWidget(_TestConfigurationWidget(
        key: testKey,
        state: const Value.success(1).toFailure(
          'Error',
          isFetching: false,
        ),
        valueMixedWithError: true,
      ));

      expect(find.byKey(_buildWidgetKey), findsNothing);
      expect(find.byKey(_errorWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsOneWidget);
    });

    testWidgets('build with ${Value<int>}.failure', (tester) async {
      final testKey = GlobalKey<_TestConfigurationWidgetState>();
      await tester.pumpWidget(_TestConfigurationWidget(
        key: testKey,
        state: const Value.success(1).toFailure(
          'Error',
          isFetching: false,
        ),
      ));

      expect(find.byKey(_errorWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsOneWidget);

      testKey.currentState!.updateOnError((context, state) {
        return Container(key: _errorWidgetKey);
      });

      await tester.pumpAndSettle();

      expect(find.byKey(_errorWidgetKey), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsNothing);
    });

    testWidgets(
        'build with ${Value<int>}.failure with data and valueMixedWithError',
        (tester) async {
      final testKey = GlobalKey<_TestConfigurationWidgetState>();
      await tester.pumpWidget(_TestConfigurationWidget(
        key: testKey,
        state: const Value.success(1).toFailure(
          'Error',
          isFetching: false,
        ),
        valueMixedWithError: true,
      ));

      expect(find.byKey(_buildWidgetKey), findsOneWidget);
      expect(find.byKey(_errorWidgetKey), findsOneWidget);
      expect(find.byType(_defaultWidgetType), findsNWidgets(2));
    });
  });
}
