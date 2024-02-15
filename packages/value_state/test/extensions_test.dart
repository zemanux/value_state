import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

void main() {
  const myStr = 'My String';
  const myError = 'Error';

  group('test ValueExtensions', () {
    const initial = Value<String>.initial();
    final success = Value<String>.success(myStr);

    final failure = Value<String>.failure(myError);
    final failureWithData = success.toFailure(myError);

    test('toSuccess', () {
      expect(initial.toSuccess(myStr), Value<String>.success(myStr));
      expect(initial.toSuccess(myStr, isFetching: true),
          Value<String>.success(myStr, isFetching: true));
      expect(initial.toFailure(myError), Value<String>.failure(myError));
      expect(initial.toFailure(myError, isFetching: true),
          Value<String>.failure(myError, isFetching: true));

      expect(success.toSuccess(myStr), Value<String>.success(myStr));
      expect(success.toSuccess(myStr, isFetching: true),
          Value<String>.success(myStr, isFetching: true));

      expect(failure.toSuccess(myStr), Value<String>.success(myStr));
      expect(failure.toSuccess(myStr, isFetching: true),
          Value<String>.success(myStr, isFetching: true));

      expect(failureWithData.toSuccess(myStr), Value<String>.success(myStr));
      expect(failureWithData.toSuccess(myStr, isFetching: true),
          Value<String>.success(myStr, isFetching: true));
    });

    test('toFailure', () {
      expect(initial.toFailure(myError), Value<String>.failure(myError));
      expect(initial.toFailure(myError, isFetching: true),
          Value<String>.failure(myError, isFetching: true));

      expect(failure.toFailure(myError), Value<String>.failure(myError));
      expect(failure.toFailure(myError, isFetching: true),
          Value<String>.failure(myError, isFetching: true));

      expect(
        failureWithData,
        isA<Value<String>>()
            .having((value) => value.isFetching, 'is not fetching', false)
            .having((value) => value.isFailure, 'is failure', true)
            .having(
              (value) => value.error,
              'failure content',
              myError,
            ),
      );
      expect(
        success.toFailure(myError, isFetching: true),
        isA<Value<String>>()
            .having((value) => value.isFetching, 'is fetching', true)
            .having((value) => value.isFailure, 'is failure', true)
            .having(
              (value) => value.error,
              'failure content',
              myError,
            ),
      );
    });
  });

  group('test Future.toValues', () {
    test('on success', () {
      expect(
          Future.value(myStr).toValues(),
          emitsInOrder([
            const Value<String>.initial(isFetching: true),
            Value<String>.success(myStr),
            emitsDone,
          ]));
    });

    test('on failure', () {
      expect(
          Future<String>(() => throw myError).toValues(),
          emitsInOrder([
            const Value<String>.initial(isFetching: true),
            isA<Value<String>>()
                .having((value) => value.isFetching, 'is not fetching', false)
                .having((value) => value.isFailure, 'is failure', true)
                .having(
                  (value) => value.error,
                  'failure content',
                  myError,
                ),
            emitsDone,
          ]));
    });

    test('on failure without guard', () {
      expect(
          Future<String>(() => throw myError).toValues(guarded: false),
          emitsInOrder([
            const Value<String>.initial(isFetching: true),
            isA<Value<String>>()
                .having((value) => value.isFetching, 'is not fetching', false)
                .having((value) => value.isFailure, 'is failure', true)
                .having(
                  (value) => value.error,
                  'failure content',
                  myError,
                ),
            emitsDone,
          ]));
    });
  });
}
