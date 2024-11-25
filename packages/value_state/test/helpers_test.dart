import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

void main() {
  test('perform on ${Value<int>}', () {
    final stream = const Value.success(1).fetch(() async => 2);

    expect(
        stream,
        emitsInOrder([
          const Value.success(1, isFetching: true),
          const Value.success(2, isFetching: false),
          emitsDone,
        ]));
  });

  test('performStream on ${Value<int>}', () {
    final stream = const Value.success(1).fetchStream(
      Stream.fromIterable([2, 3]),
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
}
