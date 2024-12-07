import 'package:flutter/material.dart';
import 'package:value_state/value_state.dart';

import 'logic/counter_value_notifier.dart';
import 'widgets/action_button.dart';
import 'widgets/app_root.dart';
import 'widgets/default_error.dart';
import 'widgets/formatted_column.dart';
import 'widgets/loader.dart';

// coverage:ignore-start
void main() {
  runApp(const MyApp());
}
// coverage:ignore-end

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => const AppRoot(child: MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _notifier = CounterNotifier();

  @override
  Widget build(BuildContext context) {
    // This example, show how to handle different states with refetching
    // problematic. In this case, when an error is raised after a value has
    // been successfully fetched, we can see the error and the last value
    // fetched both displayed.
    return ValueListenableBuilder(
      valueListenable: _notifier,
      builder: (context, state, _) {
        if (state.isInitial) return const Loader();

        return FormattedColumn(children: [
          RefreshLoader(isLoading: state.isRefetching),
          if (state case Value(:final error?)) DefaultError(error: error),
          if (state case Value(:final data?)) Text('Counter value : $data'),
          ActionButton(
            onPressed: state.isRefetching ? null : _notifier.increment,
          ),
        ]);
      },
    );
  }
}
