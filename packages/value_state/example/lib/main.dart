import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_state/value_state.dart';

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
        title: 'Value State Demo',
        home: Scaffold(
          appBar: AppBar(title: const Text('Flutter Demo Home Page')),
          body: const DefaultTextStyle(
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
            child: MyHomePage(),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // This example, show how to handle different states with refreshing
    // problematic. In this case, when an error is raised after a value has
    // been successfully fetched, we can show the error and the last value
    // fetched.
    return BlocBuilder<CounterCubit, Value<int>>(
      builder: (context, state) => switch (state) {
        Value(:final data?, :final isRefreshing, :final error) =>
          _FormattedColumn(children: [
            _DefaultLoader(isLoading: isRefreshing),
            if (error != null) _ErrorWidget(error: error),
            Text('Counter value : $data'),
            Center(child: _ActionButton(isRefreshing: isRefreshing)),
          ]),
        Value(:final error?) => _ErrorWidget(error: error),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );

    // You can try by replacing the previous builder by this one without mixing
    // old value and error.
    // return BlocBuilder<CounterCubit, Value<int>>(
    //   builder: (context, state) => switch (state) {
    //     Value(isSuccess: true, :final data?, :final isRefreshing) =>
    //       _FormattedColumn(children: [
    //         _DefaultLoader(isLoading: isRefreshing),
    //         Text('Counter value : $data'),
    //         Center(child: _ActionButton(isRefreshing: isRefreshing)),
    //       ]),
    //     Value(:final error?, :final isRefreshing) =>
    //       _FormattedColumn(children: [
    //         _ErrorWidget(error: error),
    //         Center(child: _ActionButton(isRefreshing: isRefreshing)),
    //       ]),
    //     _ => const Center(child: CircularProgressIndicator()),
    //   },
    // );
  }
}

class _FormattedColumn extends StatelessWidget {
  const _FormattedColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
        alignment: Alignment.topCenter,
        heightFactor: 0.75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
}

class _DefaultLoader extends StatelessWidget {
  const _DefaultLoader({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isLoading,
      child: const Align(
        heightFactor: 0,
        alignment: Alignment.topCenter,
        child: LinearProgressIndicator(),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Expected error.',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.isRefreshing});

  final bool isRefreshing;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: isRefreshing ? null : context.read<CounterCubit>().increment,
        child: const Text('Increment'),
      );
}
