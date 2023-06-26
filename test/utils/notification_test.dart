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
        RxNotification.data(value1).hashCode,
        RxNotification.data(value1).hashCode,
      );
      expect(
        RxNotification.data(value1).hashCode,
        RxNotification<num>.data(value1).hashCode,
      );
      expect(
        RxNotification.data(value1).hashCode,
        isNot(RxNotification.data(value2).hashCode),
      );

      expect(
        RxNotification<int>.done().hashCode,
        RxNotification<int>.done().hashCode,
      );
      expect(
        RxNotification<int>.done().hashCode,
        RxNotification<String>.done().hashCode,
      );

      expect(
        RxNotification<int>.error(value1, st1).hashCode,
        RxNotification<int>.error(value1, st1).hashCode,
      );
      expect(
        RxNotification<int>.error(value1, st1).hashCode,
        isNot(RxNotification<int>.error(value2, st1).hashCode),
      );
      expect(
        RxNotification<int>.error(value1, st1).hashCode,
        isNot(RxNotification<int>.error(value1, st2).hashCode),
      );
      expect(
        RxNotification<int>.error(value1, st1).hashCode,
        isNot(RxNotification<int>.error(value2, st2).hashCode),
      );

      expect(
        RxNotification.data(value1).hashCode,
        isNot(RxNotification<int>.done().hashCode),
      );
      expect(
        RxNotification.data(value1).hashCode,
        isNot(RxNotification<int>.error(value1, st1).hashCode),
      );
      expect(
        RxNotification<int>.done().hashCode,
        isNot(RxNotification<int>.error(value1, st1).hashCode),
      );
    });

    test('==', () {
      final value1 = 1;
      final value2 = 2;

      final st1 = StackTrace.current;
      final st2 = StackTrace.current;

      expect(
        RxNotification.data(value1),
        RxNotification.data(value1),
      );
      expect(
        RxNotification.data(value1),
        isNot(RxNotification<num>.data(value1)),
      );
      expect(
        RxNotification.data(value1),
        isNot(RxNotification.data(value2)),
      );

      expect(
        RxNotification<int>.done(),
        RxNotification<int>.done(),
      );
      expect(
        RxNotification<int>.done(),
        RxNotification<String>.done(),
      );

      expect(
        RxNotification<int>.error(value1, st1),
        RxNotification<int>.error(value1, st1),
      );
      expect(
        RxNotification<int>.error(value1, st1),
        isNot(RxNotification<int>.error(value2, st1)),
      );
      expect(
        RxNotification<int>.error(value1, st1),
        isNot(RxNotification<int>.error(value1, st2)),
      );
      expect(
        RxNotification<int>.error(value1, st1),
        isNot(RxNotification<int>.error(value2, st2)),
      );

      expect(
        RxNotification.data(value1),
        isNot(RxNotification<int>.done()),
      );
      expect(
        RxNotification.data(value1),
        isNot(RxNotification<int>.error(value1, st1)),
      );
      expect(
        RxNotification<int>.done(),
        isNot(RxNotification<int>.error(value1, st1)),
      );
    });

    test('toString', () {
      expect(
        RxNotification.data(1).toString(),
        'DataNotification{value: 1}',
      );

      expect(
        RxNotification<int>.done().toString(),
        'DoneNotification{}',
      );

      expect(
        RxNotification<int>.error(2, StackTrace.empty).toString(),
        'ErrorNotification{error: 2, stackTrace: }',
      );
    });

    test('requireData', () {
      expect(
        RxNotification.data(1).requireDataValue,
        1,
      );

      expect(
        () => RxNotification<int>.done().requireDataValue,
        throwsA(isA<TypeError>()),
      );

      expect(
        () => RxNotification<int>.error(2, StackTrace.empty).requireDataValue,
        throwsA(isA<TypeError>()),
      );
    });

    test('errorAndStackTraceOrNull', () {
      expect(
        RxNotification.data(1).errorAndStackTraceOrNull,
        isNull,
      );

      expect(
        RxNotification<int>.done().errorAndStackTraceOrNull,
        isNull,
      );

      expect(
        RxNotification<int>.error(2, StackTrace.empty).errorAndStackTraceOrNull,
        ErrorAndStackTrace(2, StackTrace.empty),
      );
    });

    test('isOnData', () {
      expect(
        RxNotification.data(1).isData,
        isTrue,
      );

      expect(
        RxNotification<int>.done().isData,
        isFalse,
      );

      expect(
        RxNotification<int>.error(2, StackTrace.empty).isData,
        isFalse,
      );
    });

    test('isOnDone', () {
      expect(
        RxNotification.data(1).isDone,
        isFalse,
      );

      expect(
        RxNotification<int>.done().isDone,
        isTrue,
      );

      expect(
        RxNotification<int>.error(2, StackTrace.empty).isDone,
        isFalse,
      );
    });

    test('isOnError', () {
      expect(
        RxNotification.data(1).isError,
        isFalse,
      );

      expect(
        RxNotification<int>.done().isError,
        isFalse,
      );

      expect(
        RxNotification<int>.error(2, StackTrace.empty).isError,
        isTrue,
      );
    });
  });
}
