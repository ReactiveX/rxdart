import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/futures/as_observable_future.dart';
import 'package:rxdart/src/futures/stream_min_future.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.min', () async {
    await expectLater(Observable<int>(_getStream()).min(), completion(0));
  });

  test('rx.Observable.min.with.comparator', () async {
    await expectLater(
        Observable<String>.fromIterable(<String>["one", "two", "three"])
            .min((String a, String b) => a.length - b.length),
        completion("one"));
  });

  test('returns an AsObservableFuture', () async {
    await expectLater(
        Observable<String>.fromIterable(<String>["one", "two", "three"])
            .min((String a, String b) => a.length - b.length),
        TypeMatcher<AsObservableFuture<String>>());
  });

  group('MinFuture', () {
    test('emits the minimum value from a list without a comparator', () async {
      await expectLater(StreamMinFuture<int>(_getStream()), completion(0));
    });

    test('emits the minimum value from a list with a comparator', () async {
      final stream = Stream.fromIterable(const ["one", "two", "three"]);

      final Comparator<String> stringLengthComparator =
          (String a, String b) => a.length - b.length;

      await expectLater(StreamMinFuture<String>(stream, stringLengthComparator),
          completion("one"));
    });

    test('throws the exception when encountered in the stream', () async {
      final Stream<int> stream = ConcatStream<int>(<Stream<int>>[
        Stream<int>.fromIterable(<int>[1]),
        ErrorStream<int>(Exception())
      ]);

      await expectLater(StreamMinFuture<int>(stream), throwsException);
    });

    test('rx.Observable.min.error.comparator', () async {
      final stream =
          Stream.fromIterable([ErrorComparator(), ErrorComparator()]);

      await expectLater(
          StreamMinFuture<ErrorComparator>(stream), throwsException);
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
