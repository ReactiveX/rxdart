import 'package:rxdart/src/streams/single.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('Single.empty', () {
    final single = Single<void>.fromStream(Stream.empty());

    expect(
      single,
      emitsInOrder(<dynamic>[emitsError(isA<SingleError>()), emitsDone]),
    );
  });

  test('Single.once.value', () {
    final single = Single.fromStream(Stream.value(1));

    expect(
      single,
      emitsInOrder(<dynamic>[1, emitsDone]),
    );
  });

  test('Single.once.error', () {
    final single = Single<void>.fromStream(Stream.error(Exception('Error')));

    expect(
      single,
      emitsInOrder(<dynamic>[emitsError(isA<Exception>()), emitsDone]),
    );
  });

  test('Single.many.value', () {
    final single = Single.fromStream(Stream.fromIterable([1, 2]));

    expect(
      single,
      emitsInOrder(<dynamic>[emitsError(isA<SingleError>()), emitsDone]),
    );
  });

  test('Single.many.error', () {
    final single = Single<void>.fromStream(Stream.fromFutures([
      Future.error(Exception('Error')),
      Future.error(Exception('Error')),
    ]));

    expect(
      single,
      emitsInOrder(<dynamic>[emitsError(isA<SingleError>()), emitsDone]),
    );
  });

  test('Single.value_and_error', () {
    final single = Single<int>.fromStream(Stream.fromFutures([
      Future.value(1),
      Future.error(Exception('Error')),
    ]));

    expect(
      single,
      emitsInOrder(<dynamic>[emitsError(isA<SingleError>()), emitsDone]),
    );
  });

  test('Single.error_and_value', () {
    final single = Single<int>.fromStream(Stream.fromFutures([
      Future.error(Exception('Error')),
      Future.value(1),
    ]));

    expect(
      single,
      emitsInOrder(<dynamic>[emitsError(isA<SingleError>()), emitsDone]),
    );
  });
}
