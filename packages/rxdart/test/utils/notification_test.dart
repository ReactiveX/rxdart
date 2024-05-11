import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('StreamNotification', () {
    test('hashCode', () {
      final value1 = 1;
      final value2 = 2;

      final st1 = StackTrace.current;
      final st2 = StackTrace.current;

      expect(
        StreamNotification.data(value1).hashCode,
        StreamNotification.data(value1).hashCode,
      );
      expect(
        StreamNotification.data(value1).hashCode,
        StreamNotification<num>.data(value1).hashCode,
      );
      expect(
        StreamNotification.data(value1).hashCode,
        isNot(StreamNotification.data(value2).hashCode),
      );

      expect(
        StreamNotification<int>.done().hashCode,
        StreamNotification<int>.done().hashCode,
      );
      expect(
        StreamNotification<int>.done().hashCode,
        StreamNotification<String>.done().hashCode,
      );

      expect(
        StreamNotification<int>.error(value1, st1).hashCode,
        StreamNotification<int>.error(value1, st1).hashCode,
      );
      expect(
        StreamNotification<int>.error(value1, st1).hashCode,
        isNot(StreamNotification<int>.error(value2, st1).hashCode),
      );
      expect(
        StreamNotification<int>.error(value1, st1).hashCode,
        isNot(StreamNotification<int>.error(value1, st2).hashCode),
      );
      expect(
        StreamNotification<int>.error(value1, st1).hashCode,
        isNot(StreamNotification<int>.error(value2, st2).hashCode),
      );

      expect(
        StreamNotification.data(value1).hashCode,
        isNot(StreamNotification<int>.done().hashCode),
      );
      expect(
        StreamNotification.data(value1).hashCode,
        isNot(StreamNotification<int>.error(value1, st1).hashCode),
      );
      expect(
        StreamNotification<int>.done().hashCode,
        isNot(StreamNotification<int>.error(value1, st1).hashCode),
      );
    });

    test('==', () {
      final value1 = 1;
      final value2 = 2;

      final st1 = StackTrace.current;
      final st2 = StackTrace.current;

      expect(
        StreamNotification.data(value1),
        StreamNotification.data(value1),
      );
      expect(
        StreamNotification.data(value1),
        isNot(StreamNotification<num>.data(value1)),
      );
      expect(
        StreamNotification.data(value1),
        isNot(StreamNotification.data(value2)),
      );

      expect(
        StreamNotification<int>.done(),
        StreamNotification<int>.done(),
      );
      expect(
        const StreamNotification<int>.done(),
        StreamNotification<int>.done(),
      );
      expect(
        StreamNotification<int>.done(),
        StreamNotification<String>.done(),
      );

      expect(
        StreamNotification<int>.error(value1, st1),
        StreamNotification<int>.error(value1, st1),
      );
      expect(
        StreamNotification<int>.error(value1, st1),
        isNot(StreamNotification<int>.error(value2, st1)),
      );
      expect(
        StreamNotification<int>.error(value1, st1),
        isNot(StreamNotification<int>.error(value1, st2)),
      );
      expect(
        StreamNotification<int>.error(value1, st1),
        isNot(StreamNotification<int>.error(value2, st2)),
      );

      expect(
        StreamNotification.data(value1),
        isNot(StreamNotification<int>.done()),
      );
      expect(
        StreamNotification.data(value1),
        isNot(StreamNotification<int>.error(value1, st1)),
      );
      expect(
        StreamNotification<int>.done(),
        isNot(StreamNotification<int>.error(value1, st1)),
      );
    });

    test('toString', () {
      expect(
        StreamNotification.data(1).toString(),
        'DataNotification{value: 1}',
      );

      expect(
        StreamNotification<int>.done().toString(),
        'DoneNotification{}',
      );

      expect(
        StreamNotification<int>.error(2, StackTrace.empty).toString(),
        'ErrorNotification{error: 2, stackTrace: }',
      );
    });

    test('requireData', () {
      expect(
        StreamNotification.data(1).requireDataValue,
        1,
      );

      expect(
        () => StreamNotification<int>.done().requireDataValue,
        throwsA(isA<TypeError>()),
      );

      expect(
        () =>
            StreamNotification<int>.error(2, StackTrace.empty).requireDataValue,
        throwsA(isA<TypeError>()),
      );
    });

    test('errorAndStackTraceOrNull', () {
      expect(
        StreamNotification.data(1).errorAndStackTraceOrNull,
        isNull,
      );

      expect(
        StreamNotification<int>.done().errorAndStackTraceOrNull,
        isNull,
      );

      expect(
        StreamNotification<int>.error(2, StackTrace.empty)
            .errorAndStackTraceOrNull,
        ErrorAndStackTrace(2, StackTrace.empty),
      );
    });

    test('isOnData', () {
      expect(
        StreamNotification.data(1).isData,
        isTrue,
      );

      expect(
        StreamNotification<int>.done().isData,
        isFalse,
      );

      expect(
        StreamNotification<int>.error(2, StackTrace.empty).isData,
        isFalse,
      );
    });

    test('isOnDone', () {
      expect(
        StreamNotification.data(1).isDone,
        isFalse,
      );

      expect(
        StreamNotification<int>.done().isDone,
        isTrue,
      );

      expect(
        StreamNotification<int>.error(2, StackTrace.empty).isDone,
        isFalse,
      );
    });

    test('isOnError', () {
      expect(
        StreamNotification.data(1).isError,
        isFalse,
      );

      expect(
        StreamNotification<int>.done().isError,
        isFalse,
      );

      expect(
        StreamNotification<int>.error(2, StackTrace.empty).isError,
        isTrue,
      );
    });
  });
}
