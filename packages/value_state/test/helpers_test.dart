import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

void main() {
  test('fetch on ${Value<int>}', () {
    final stream = const Value.success(1).fetch(() async => 2);

    expect(
        stream,
        emitsInOrder([
          const Value.success(1, isFetching: true),
          const Value.success(2, isFetching: false),
          emitsDone,
        ]));
  });

  group('fetchStream', () {
    test('success', () {
      final stream = const Value.success(1).fetchStream(
        () => Stream.fromIterable(const [Value.success(2), Value.success(3)]),
      );

      expect(
        stream,
        emitsInOrder([
          const Value.success(1, isFetching: true),
          const Value.success(2, isFetching: false),
          const Value.success(3, isFetching: false),
          emitsDone,
        ]),
      );
    });

    final myException = Exception('My exception');

    test('failure with lastValueOnError set to false', () {
      final stream = const Value.success(1).fetchStream(() async* {
        yield const Value.success(2);
        yield const Value.success(3);
        throw myException;
      });

      expect(
        stream,
        emitsInOrder([
          const Value.success(1, isFetching: true),
          const Value.success(2, isFetching: false),
          const Value.success(3, isFetching: false),
          isA<Value>()
              .having((v) => v.error, 'error', myException)
              .having((v) => v.data, 'data', 1),
          emitsDone,
        ]),
      );
    });

    test('failure with lastValueOnError set to true', () {
      final stream = const Value.success(1).fetchStream(
        () async* {
          yield const Value.success(2);
          yield const Value.success(3);
          throw myException;
        },
        lastValueOnError: true,
      );

      expect(
        stream,
        emitsInOrder([
          const Value.success(1, isFetching: true),
          const Value.success(2, isFetching: false),
          const Value.success(3, isFetching: false),
          isA<Value>()
              .having((v) => v.error, 'error', myException)
              .having((v) => v.data, 'data', 3),
          emitsDone,
        ]),
      );
    });
  });
}
