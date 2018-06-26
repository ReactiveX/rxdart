import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/futures/as_observable_future.dart';
import 'package:rxdart/src/futures/stream_min_future.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.min', () async {
    await expectLater(new Observable<int>(_getStream()).min(), completion(0));
  });

  test('rx.Observable.min.with.comparator', () async {
    await expectLater(
        new Observable<String>.fromIterable(<String>["one", "two", "three"])
            .min((String a, String b) => a.length - b.length),
        completion("one"));
  });

  test('returns an AsObservableFuture', () async {
    await expectLater(
        new Observable<String>.fromIterable(<String>["one", "two", "three"])
            .min((String a, String b) => a.length - b.length),
        new TypeMatcher<AsObservableFuture<String>>());
  });

  group('MinFuture', () {
    test('emits the minimum value from a list without a comparator', () async {
      await expectLater(new StreamMinFuture<int>(_getStream()), completion(0));
    });

    test('emits the minimum value from a list with a comparator', () async {
      final Stream<String> stream =
          new Stream<String>.fromIterable(<String>["one", "two", "three"]);

      final Comparator<String> stringLengthComparator =
          (String a, String b) => a.length - b.length;

      await expectLater(
          new StreamMinFuture<String>(stream, stringLengthComparator),
          completion("one"));
    });

    test('throws the exception when encountered in the stream', () async {
      final Stream<int> stream = new ConcatStream<int>(<Stream<int>>[
        new Stream<int>.fromIterable(<int>[1]),
        new ErrorStream<int>(new Exception())
      ]);

      await expectLater(new StreamMinFuture<int>(stream), throwsException);
    });

    test('rx.Observable.min.error.comparator', () async {
      Stream<ErrorComparator> stream = new Stream<ErrorComparator>.fromIterable(
          <ErrorComparator>[new ErrorComparator(), new ErrorComparator()]);

      await expectLater(
          new StreamMinFuture<ErrorComparator>(stream), throwsException);
    });
  });
}

class ErrorComparator implements Comparable<ErrorComparator> {
  @override
  int compareTo(ErrorComparator other) {
    throw new Exception();
  }
}

Stream<int> _getStream() =>
    new Stream<int>.fromIterable(const <int>[2, 3, 3, 5, 2, 9, 1, 2, 0]);
