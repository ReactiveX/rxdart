import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('RxNotification', () {
    test('hashCode', () {
      final value1 = 1;
      final value2 = 2;

      final st1 = StackTrace.current;
      final st2 = StackTrace.current;

      expect(
        RxNotification.onData(value1).hashCode,
        RxNotification.onData(value1).hashCode,
      );
      expect(
        RxNotification.onData(value1).hashCode,
        RxNotification<num>.onData(value1).hashCode,
      );
      expect(
        RxNotification.onData(value1).hashCode,
        isNot(RxNotification.onData(value2).hashCode),
      );

      expect(
        RxNotification<int>.onDone().hashCode,
        RxNotification<int>.onDone().hashCode,
      );
      expect(
        RxNotification<int>.onDone().hashCode,
        RxNotification<String>.onDone().hashCode,
      );

      expect(
        RxNotification<int>.onError(value1, st1).hashCode,
        RxNotification<int>.onError(value1, st1).hashCode,
      );
      expect(
        RxNotification<int>.onError(value1, st1).hashCode,
        isNot(RxNotification<int>.onError(value2, st1).hashCode),
      );
      expect(
        RxNotification<int>.onError(value1, st1).hashCode,
        isNot(RxNotification<int>.onError(value1, st2).hashCode),
      );
      expect(
        RxNotification<int>.onError(value1, st1).hashCode,
        isNot(RxNotification<int>.onError(value2, st2).hashCode),
      );

      expect(
        RxNotification.onData(value1).hashCode,
        isNot(RxNotification<int>.onDone().hashCode),
      );
      expect(
        RxNotification.onData(value1).hashCode,
        isNot(RxNotification<int>.onError(value1, st1).hashCode),
      );
      expect(
        RxNotification<int>.onDone().hashCode,
        isNot(RxNotification<int>.onError(value1, st1).hashCode),
      );
    });

    test('==', () {
      final value1 = 1;
      final value2 = 2;

      final st1 = StackTrace.current;
      final st2 = StackTrace.current;

      expect(
        RxNotification.onData(value1),
        RxNotification.onData(value1),
      );
      expect(
        RxNotification.onData(value1),
        isNot(RxNotification<num>.onData(value1)),
      );
      expect(
        RxNotification.onData(value1),
        isNot(RxNotification.onData(value2)),
      );

      expect(
        RxNotification<int>.onDone(),
        RxNotification<int>.onDone(),
      );
      expect(
        RxNotification<int>.onDone(),
        RxNotification<String>.onDone(),
      );

      expect(
        RxNotification<int>.onError(value1, st1),
        RxNotification<int>.onError(value1, st1),
      );
      expect(
        RxNotification<int>.onError(value1, st1),
        isNot(RxNotification<int>.onError(value2, st1)),
      );
      expect(
        RxNotification<int>.onError(value1, st1),
        isNot(RxNotification<int>.onError(value1, st2)),
      );
      expect(
        RxNotification<int>.onError(value1, st1),
        isNot(RxNotification<int>.onError(value2, st2)),
      );

      expect(
        RxNotification.onData(value1),
        isNot(RxNotification<int>.onDone()),
      );
      expect(
        RxNotification.onData(value1),
        isNot(RxNotification<int>.onError(value1, st1)),
      );
      expect(
        RxNotification<int>.onDone(),
        isNot(RxNotification<int>.onError(value1, st1)),
      );
    });

    test('toString', () {
      expect(
        RxNotification.onData(1).toString(),
        'RxNotification.onData{value: 1}',
      );

      expect(
        RxNotification<int>.onDone().toString(),
        'RxNotification.onDone',
      );

      expect(
        RxNotification<int>.onError(2, StackTrace.empty).toString(),
        'RxNotification.onError{error: 2, stackTrace: }',
      );
    });

    test('requireData', () {
      expect(
        RxNotification.onData(1).requireData,
        1,
      );

      expect(
        () => RxNotification<int>.onDone().requireData,
        throwsStateError,
      );

      expect(
        () => RxNotification<int>.onError(2, StackTrace.empty).requireData,
        throwsStateError,
      );
    });

    test('errorAndStackTrace', () {
      expect(
        RxNotification.onData(1).errorAndStackTrace,
        isNull,
      );

      expect(
        RxNotification<int>.onDone().errorAndStackTrace,
        isNull,
      );

      expect(
        RxNotification<int>.onError(2, StackTrace.empty).errorAndStackTrace,
        ErrorAndStackTrace(2, StackTrace.empty),
      );
    });

    test('isOnData', () {
      expect(
        RxNotification.onData(1).isOnData,
        isTrue,
      );

      expect(
        RxNotification<int>.onDone().isOnData,
        isFalse,
      );

      expect(
        RxNotification<int>.onError(2, StackTrace.empty).isOnData,
        isFalse,
      );
    });

    test('isOnDone', () {
      expect(
        RxNotification.onData(1).isOnDone,
        isFalse,
      );

      expect(
        RxNotification<int>.onDone().isOnDone,
        isTrue,
      );

      expect(
        RxNotification<int>.onError(2, StackTrace.empty).isOnDone,
        isFalse,
      );
    });

    test('isOnError', () {
      expect(
        RxNotification.onData(1).isOnError,
        isFalse,
      );

      expect(
        RxNotification<int>.onDone().isOnError,
        isFalse,
      );

      expect(
        RxNotification<int>.onError(2, StackTrace.empty).isOnError,
        isTrue,
      );
    });
  });
}
