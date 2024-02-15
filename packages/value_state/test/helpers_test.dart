import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

void main() {
  test('perform on ${Value<int>}', () {
    final stream = Value.success(1).fetch(() async => Value.success(2));

    expect(
        stream,
        emitsInOrder([
          Value.success(1, isFetching: true),
          Value.success(2, isFetching: false),
        ]));
  });

  test('performStream on ${Value<int>}', () {
    final stream = Value.success(1).fetchStream(
      Stream.fromIterable([
        Value.success(2),
        Value.success(3),
      ]),
    );

    expect(
      stream,
      emitsInOrder([
        Value.success(1, isFetching: true),
        Value.success(2, isFetching: false),
        Value.success(3, isFetching: false),
      ]),
    );
  });
}
