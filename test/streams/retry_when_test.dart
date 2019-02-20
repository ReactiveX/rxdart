import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/streams/utils.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.retryWhen', () {
    expect(
      Observable.retryWhen(_sourceStream(3), _alwaysThrow),
      emitsInOrder(<dynamic>[0, 1, 2, emitsDone]),
    );
  });

  test('RetryWhenStream', () {
    expect(
      RetryWhenStream(_sourceStream(3), _alwaysThrow),
      emitsInOrder(<dynamic>[0, 1, 2, emitsDone]),
    );
  });

  test('RetryWhenStream.onDone', () {
    expect(
      RetryWhenStream(_sourceStream(3), _alwaysThrow),
      emitsInOrder(<dynamic>[0, 1, 2, emitsDone]),
    );
  });

  test('RetryWhenStream.infinite.retries', () {
    expect(
      RetryWhenStream(_sourceStream(1000, 2), _neverThrow).take(6),
      emitsInOrder(<dynamic>[0, 1, 0, 1, 0, 1, emitsDone]),
    );
  });

  test('RetryWhenStream.emits.original.items', () {
    const retries = 3;

    expect(
      RetryWhenStream(_getStreamWithExtras(retries), _neverThrow).take(6),
      emitsInOrder(<dynamic>[1, 1, 1, 2, emitsDone]),
    );
  });

  test('RetryWhenStream.single.subscription', () {
    final stream = RetryWhenStream(_sourceStream(3), _neverThrow);
    try {
      stream.listen(null);
      stream.listen(null);
    } catch (e) {
      expect(e, isStateError);
    }
  });

  test('RetryWhenStream.asBroadcastStream', () {
    final stream =
        RetryWhenStream(_sourceStream(3), _neverThrow).asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    expect(stream.isBroadcast, isTrue);
  });

  test('RetryWhenStream.error.shouldThrow', () {
    final observableWithError =
        RetryWhenStream(_sourceStream(3, 0), _alwaysThrow);

    expect(
        observableWithError,
        emitsInOrder(
            <dynamic>[emitsError(TypeMatcher<RetryError>()), emitsDone]));
  });

  test('RetryWhenStream.error.capturesErrors', () async {
    final observableWithError =
        RetryWhenStream(_sourceStream(3, 0), _alwaysThrow);

    await expectLater(
        observableWithError,
        emitsInOrder(<dynamic>[
          emitsError(
            predicate<RetryError>((a) {
              return a.errors.length == 1 &&
                  a.errors
                      .every((es) => es.error != null && es.stacktrace != null);
            }),
          ),
          emitsDone,
        ]));
  });

  test('RetryWhenStream.pause.resume', () async {
    StreamSubscription<int> subscription;

    subscription = RetryWhenStream(_sourceStream(3), _neverThrow)
        .listen(expectAsync1((result) {
      expect(result, 0);

      subscription.cancel();
    }));

    subscription.pause();
    subscription.resume();
  });
}

StreamFactory<int> _sourceStream(int i, [int throwAt]) {
  return throwAt == null
      ? () => Observable.fromIterable(range(i))
      : () => Observable.fromIterable(range(i))
          .map((i) => i == throwAt ? throw i : i);
}

Stream<void> _alwaysThrow(dynamic e, StackTrace s) =>
    Observable<void>.error(Error());

Stream<void> _neverThrow(dynamic e, StackTrace s) => Observable.just('');

StreamFactory<int> _getStreamWithExtras(int failCount) {
  var count = 0;

  return () {
    if (count < failCount) {
      count++;

      // Emit first item
      return Observable.just(1)
          // Emit the error
          .concatWith([ErrorStream<int>(Error())])
          // Emit an extra item, testing that it is not included
          .concatWith([Observable.just(1)]);
    } else {
      return Observable.just(2);
    }
  };
}

// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Returns an [Iterable] sequence of [int]s.
///
/// If only one argument is provided, [start_or_stop] is the upper bound for
/// the sequence. If two or more arguments are provided, [stop] is the upper
/// bound.
///
/// The sequence starts at 0 if one argument is provided, or [start_or_stop] if
/// two or more arguments are provided. The sequence increments by 1, or [step]
/// if provided. [step] can be negative, in which case the sequence counts down
/// from the starting point and [stop] must be less than the starting point so
/// that it becomes the lower bound.
Iterable<int> range(int start_or_stop, [int stop, int step]) sync* {
  final start = stop == null ? 0 : start_or_stop;
  stop ??= start_or_stop;
  step ??= 1;

  if (step == 0) throw ArgumentError('step cannot be 0');
  if (step > 0 && stop < start)
    throw ArgumentError('if step is positive,'
        ' stop must be greater than start');
  if (step < 0 && stop > start)
    throw ArgumentError('if step is negative,'
        ' stop must be less than start');

  for (var value = start; step < 0 ? value > stop : value < stop; value += step)
    yield value;
}
