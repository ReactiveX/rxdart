import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('Notification', () {
    test('hashCode', () {
      final value1 = 1;
      final value2 = 2;

      final st1 = StackTrace.current;
      final st2 = StackTrace.current;

      expect(
        Notification.onData(value1).hashCode,
        Notification.onData(value1).hashCode,
      );
      expect(
        Notification.onData(value1).hashCode,
        Notification<num>.onData(value1).hashCode,
      );
      expect(
        Notification.onData(value1).hashCode,
        isNot(Notification.onData(value2).hashCode),
      );

      expect(
        Notification<int>.onDone().hashCode,
        Notification<int>.onDone().hashCode,
      );
      expect(
        Notification<int>.onDone().hashCode,
        Notification<String>.onDone().hashCode,
      );

      expect(
        Notification<int>.onError(value1, st1).hashCode,
        Notification<int>.onError(value1, st1).hashCode,
      );
      expect(
        Notification<int>.onError(value1, st1).hashCode,
        isNot(Notification<int>.onError(value2, st1).hashCode),
      );
      expect(
        Notification<int>.onError(value1, st1).hashCode,
        isNot(Notification<int>.onError(value1, st2).hashCode),
      );
      expect(
        Notification<int>.onError(value1, st1).hashCode,
        isNot(Notification<int>.onError(value2, st2).hashCode),
      );

      expect(
        Notification.onData(value1).hashCode,
        isNot(Notification<int>.onDone().hashCode),
      );
      expect(
        Notification.onData(value1).hashCode,
        isNot(Notification<int>.onError(value1, st1).hashCode),
      );
      expect(
        Notification<int>.onDone().hashCode,
        isNot(Notification<int>.onError(value1, st1).hashCode),
      );
    });

    test('==', () {
      final value1 = 1;
      final value2 = 2;

      final st1 = StackTrace.current;
      final st2 = StackTrace.current;

      expect(
        Notification.onData(value1),
        Notification.onData(value1),
      );
      expect(
        Notification.onData(value1),
        isNot(Notification<num>.onData(value1)),
      );
      expect(
        Notification.onData(value1),
        isNot(Notification.onData(value2)),
      );

      expect(
        Notification<int>.onDone(),
        Notification<int>.onDone(),
      );
      expect(
        Notification<int>.onDone(),
        Notification<String>.onDone(),
      );

      expect(
        Notification<int>.onError(value1, st1),
        Notification<int>.onError(value1, st1),
      );
      expect(
        Notification<int>.onError(value1, st1),
        isNot(Notification<int>.onError(value2, st1)),
      );
      expect(
        Notification<int>.onError(value1, st1),
        isNot(Notification<int>.onError(value1, st2)),
      );
      expect(
        Notification<int>.onError(value1, st1),
        isNot(Notification<int>.onError(value2, st2)),
      );

      expect(
        Notification.onData(value1),
        isNot(Notification<int>.onDone()),
      );
      expect(
        Notification.onData(value1),
        isNot(Notification<int>.onError(value1, st1)),
      );
      expect(
        Notification<int>.onDone(),
        isNot(Notification<int>.onError(value1, st1)),
      );
    });

    test('toString', () {
      expect(
        Notification.onData(1).toString(),
        'Notification.onData{value: 1}',
      );

      expect(
        Notification<int>.onDone().toString(),
        'Notification.onDone',
      );

      expect(
        Notification<int>.onError(2, StackTrace.empty).toString(),
        'Notification.onError{error: 2, stackTrace: }',
      );
    });

    test('requireData', () {
      expect(
        Notification.onData(1).requireData,
        1,
      );

      expect(
        () => Notification<int>.onDone().requireData,
        throwsStateError,
      );

      expect(
        () => Notification<int>.onError(2, StackTrace.empty).requireData,
        throwsStateError,
      );
    });

    test('errorAndStackTrace', () {
      expect(
        Notification.onData(1).errorAndStackTrace,
        isNull,
      );

      expect(
        Notification<int>.onDone().errorAndStackTrace,
        isNull,
      );

      expect(
        Notification<int>.onError(2, StackTrace.empty).errorAndStackTrace,
        ErrorAndStackTrace(2, StackTrace.empty),
      );
    });

    test('isOnData', () {
      expect(
        Notification.onData(1).isOnData,
        isTrue,
      );

      expect(
        Notification<int>.onDone().isOnData,
        isFalse,
      );

      expect(
        Notification<int>.onError(2, StackTrace.empty).isOnData,
        isFalse,
      );
    });

    test('isOnDone', () {
      expect(
        Notification.onData(1).isOnDone,
        isFalse,
      );

      expect(
        Notification<int>.onDone().isOnDone,
        isTrue,
      );

      expect(
        Notification<int>.onError(2, StackTrace.empty).isOnDone,
        isFalse,
      );
    });

    test('isOnError', () {
      expect(
        Notification.onData(1).isOnError,
        isFalse,
      );

      expect(
        Notification<int>.onDone().isOnError,
        isFalse,
      );

      expect(
        Notification<int>.onError(2, StackTrace.empty).isOnError,
        isTrue,
      );
    });
  });
}
