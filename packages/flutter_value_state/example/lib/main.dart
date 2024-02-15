import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_value_state/flutter_value_state.dart';

import 'cubit.dart';

// coverage:ignore-start
void main() {
  runApp(const MyApp());
}
// coverage:ignore-end

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => CounterCubit(),
        child: MaterialApp(
          title: 'Value Cubit Demo',
          builder: (context, child) => child == null
              ? const SizedBox.shrink()
              : ValueBuilderConfiguration(
                  configuration: ValueBuilderConfigurationData(
                    initial: (context, state) =>
                        const Center(child: CircularProgressIndicator()),
                    failure: (context, state) => Center(
                      child: Text('Expected error.',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                    wrapper: (context, state, child) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: child),
                  ),
                  child: child,
                ),
          home: const MyHomePage(),
        ));
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CounterCubit, Value<int>>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Home Page'),
        ),
        body: DefaultTextStyle(
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
          child: state.buildWidget(
              onValue: (context, state, error) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.isFetching) const LinearProgressIndicator(),
                        const Spacer(),
                        if (error != null) error,
                        const Text('Counter value :'),
                        Text(
                          state.data.toString(),
                          style: theme.textTheme.headlineMedium,
                        ),
                        const Spacer(),
                      ]),
              valueMixedWithError: true),
        ),
        floatingActionButton: state.isInitial
            ? null
            : FloatingActionButton(
                onPressed: state.isFetching
                    ? null
                    : context.read<CounterCubit>().increment,
                tooltip: 'Increment',
                child: state.isFetching
                    ? SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary))
                    : const Icon(Icons.refresh)),
      );
    });
  }
}
