import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/futures/as_observable_future.dart';
import 'package:rxdart/src/futures/stream_max_future.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.max', () async {
    await expectLater(Observable<int>(_getStream()).max(), completion(9));
  });

  test('rx.Observable.max.with.comparator', () async {
    await expectLater(
        Observable<String>.fromIterable(<String>["one", "two", "three"])
            .max((String a, String b) => a.length - b.length),
        completion("three"));
  });

  test('returns an AsObservableFuture', () async {
    await expectLater(
        Observable<String>.fromIterable(<String>["one", "two", "three"])
            .max((String a, String b) => a.length - b.length),
        TypeMatcher<AsObservableFuture<String>>());
  });

  group('MaxFuture', () {
    test('emits the maximum value from a list without a comparator', () async {
      await expectLater(StreamMaxFuture<int>(_getStream()), completion(9));
    });

    test('emits the maximum value from a list with a comparator', () async {
      final stream = Stream.fromIterable(const ["one", "two", "three"]);

      final Comparator<String> stringLengthComparator =
          (String a, String b) => a.length - b.length;

      await expectLater(StreamMaxFuture<String>(stream, stringLengthComparator),
          completion("three"));
    });

    test('throws the exception when encountered in the stream', () async {
      final Stream<int> stream = ConcatStream<int>(<Stream<int>>[
        Stream<int>.fromIterable(<int>[1]),
        ErrorStream<int>(Exception())
      ]);

      await expectLater(StreamMaxFuture<int>(stream), throwsException);
    });

    test('rx.Observable.max.error.comparator', () async {
      final stream =
          Stream.fromIterable([ErrorComparator(), ErrorComparator()]);

      await expectLater(
          StreamMaxFuture<ErrorComparator>(stream), throwsException);
    });
  });
}

class ErrorComparator implements Comparable<ErrorComparator> {
  @override
  int compareTo(ErrorComparator other) {
    throw Exception();
  }
}

Stream<int> _getStream() =>
    Stream<int>.fromIterable(const <int>[2, 3, 3, 5, 2, 9, 1, 2, 0]);
