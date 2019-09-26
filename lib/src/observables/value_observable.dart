import 'package:rxdart/src/observables/observable.dart';
import 'package:rxdart/streams.dart';

/// An [Observable] that provides synchronous access to the last emitted item
abstract class ValueObservable<T> implements Observable<T> {
  /// Last emitted value, or null if there has been no emission yet
  /// See [hasValue]
  T get value;

  bool get hasValue;

  /// Merges the given ValueObservables into one ValueObservable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The new ValueObservable will be seeded based on the initial value of each input ValueObservable.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     final foo = ValueObservable.combineLatest3(
  ///       new Observable.just("a").shareValueSeeded("a"),
  ///       new Observable.fromIterable(["b", "b"]).shareValueSeeded("b"),
  ///       (a, b) => a + b);
  ///
  ///     print(foo.value); // prints "abc"
  ///     foo.listen(print); //prints "abc", "abc"
  static ValueObservable<T> combineLatest2<A, B, T>(ValueObservable<A> streamA,
          ValueObservable<B> streamB, T combiner(A a, B b)) =>
      Observable<T>(CombineLatestStream.combine2(
              streamA.skip(1), streamB.skip(1), combiner))
          .shareValueSeeded(combiner(streamA.value, streamB.value));

  /// Merges the given ValueObservables into one ValueObservable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The new ValueObservable will be seeded based on the initial value of each input ValueObservable.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     final foo = ValueObservable.combineLatest3(
  ///       new Observable.just("a").shareValueSeeded("a"),
  ///       new Observable.just("b").shareValueSeeded("b"),
  ///       new Observable.fromIterable(["c", "c"]).shareValueSeeded("c"),
  ///       (a, b, c) => a + b + c);
  ///
  ///     print(foo.value); // prints "abc"
  ///     foo.listen(print); //prints "abc", "abc"
  static ValueObservable<T> combineLatest3<A, B, C, T>(
          ValueObservable<A> streamA,
          ValueObservable<B> streamB,
          ValueObservable<C> streamC,
          T combiner(A a, B b, C c)) =>
      Observable<T>(CombineLatestStream.combine3(
              streamA.skip(1), streamB.skip(1), streamC.skip(1), combiner))
          .shareValueSeeded(
              combiner(streamA.value, streamB.value, streamC.value));

  /// Merges the given ValueObservables into one ValueObservable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The new ValueObservable will be seeded based on the initial value of each input ValueObservable.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     final foo = ValueObservable.combineLatest3(
  ///       new Observable.just("a").shareValueSeeded("a"),
  ///       new Observable.just("b").shareValueSeeded("b"),
  ///       new Observable.just("c").shareValueSeeded("c"),
  ///       new Observable.fromIterable(["d", "d"]).shareValueSeeded("d"),
  ///       (a, b, c, d) => a + b + c + d);
  ///
  ///     print(foo.value); // prints "abcd"
  ///     foo.listen(print); //prints "abcd", "abcd"
  static ValueObservable<T> combineLatest4<A, B, C, D, T>(
          ValueObservable<A> streamA,
          ValueObservable<B> streamB,
          ValueObservable<C> streamC,
          ValueObservable<D> streamD,
          T combiner(A a, B b, C c, D d)) =>
      Observable<T>(CombineLatestStream.combine4(streamA.skip(1),
              streamB.skip(1), streamC.skip(1), streamD.skip(1), combiner))
          .shareValueSeeded(combiner(
              streamA.value, streamB.value, streamC.value, streamD.value));

  /// Merges the given ValueObservables into one ValueObservable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The new ValueObservable will be seeded based on the initial value of each input ValueObservable.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     final foo = ValueObservable.combineLatest3(
  ///       new Observable.just("a").shareValueSeeded("a"),
  ///       new Observable.just("b").shareValueSeeded("b"),
  ///       new Observable.just("c").shareValueSeeded("c"),
  ///       new Observable.just("d").shareValueSeeded("d"),
  ///       new Observable.fromIterable(["e", "e"]).shareValueSeeded("e"),
  ///       (a, b, c, d, e) => a + b + c + d + e);
  ///
  ///     print(foo.value); // prints "abcde"
  ///     foo.listen(print); //prints "abcde", "abcde"
  static ValueObservable<T> combineLatest5<A, B, C, D, E, T>(
          ValueObservable<A> streamA,
          ValueObservable<B> streamB,
          ValueObservable<C> streamC,
          ValueObservable<D> streamD,
          ValueObservable<E> streamE,
          T combiner(A a, B b, C c, D d, E e)) =>
      Observable<T>(CombineLatestStream.combine5(
              streamA.skip(1),
              streamB.skip(1),
              streamC.skip(1),
              streamD.skip(1),
              streamE.skip(1),
              combiner))
          .shareValueSeeded(combiner(streamA.value, streamB.value,
              streamC.value, streamD.value, streamE.value));

  /// Merges the given ValueObservables into one ValueObservable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The new ValueObservable will be seeded based on the initial value of each input ValueObservable.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     final foo = ValueObservable.combineLatest3(
  ///       new Observable.just("a").shareValueSeeded("a"),
  ///       new Observable.just("b").shareValueSeeded("b"),
  ///       new Observable.just("c").shareValueSeeded("c"),
  ///       new Observable.just("d").shareValueSeeded("d"),
  ///       new Observable.just("e").shareValueSeeded("e"),
  ///       new Observable.fromIterable(["f", "f"]).shareValueSeeded("f"),
  ///       (a, b, c, d, e, f) => a + b + c + d + e + f);
  ///
  ///     print(foo.value); // prints "abcdef"
  ///     foo.listen(print); //prints "abcdef", "abcdef"
  static ValueObservable<T> combineLatest6<A, B, C, D, E, F, T>(
          ValueObservable<A> streamA,
          ValueObservable<B> streamB,
          ValueObservable<C> streamC,
          ValueObservable<D> streamD,
          ValueObservable<E> streamE,
          ValueObservable<F> streamF,
          T combiner(A a, B b, C c, D d, E e, F f)) =>
      Observable<T>(CombineLatestStream.combine6(
              streamA.skip(1),
              streamB.skip(1),
              streamC.skip(1),
              streamD.skip(1),
              streamE.skip(1),
              streamF.skip(1),
              combiner))
          .shareValueSeeded(combiner(streamA.value, streamB.value,
              streamC.value, streamD.value, streamE.value, streamF.value));

  /// Merges the given ValueObservables into one ValueObservable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The new ValueObservable will be seeded based on the initial value of each input ValueObservable.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     final foo = ValueObservable.combineLatest3(
  ///       new Observable.just("a").shareValueSeeded("a"),
  ///       new Observable.just("b").shareValueSeeded("b"),
  ///       new Observable.just("c").shareValueSeeded("c"),
  ///       new Observable.just("d").shareValueSeeded("d"),
  ///       new Observable.just("e").shareValueSeeded("e"),
  ///       new Observable.just("f").shareValueSeeded("f"),
  ///       new Observable.fromIterable(["g", "g"]).shareValueSeeded("g"),
  ///       (a, b, c, d, e, f, g) => a + b + c + d + e + f + g);
  ///
  ///     print(foo.value); // prints "abcdefg"
  ///     foo.listen(print); //prints "abcdefg", "abcdefg"
  static ValueObservable<T> combineLatest7<A, B, C, D, E, F, G, T>(
          ValueObservable<A> streamA,
          ValueObservable<B> streamB,
          ValueObservable<C> streamC,
          ValueObservable<D> streamD,
          ValueObservable<E> streamE,
          ValueObservable<F> streamF,
          ValueObservable<G> streamG,
          T combiner(A a, B b, C c, D d, E e, F f, G g)) =>
      Observable<T>(CombineLatestStream.combine7(
              streamA.skip(1),
              streamB.skip(1),
              streamC.skip(1),
              streamD.skip(1),
              streamE.skip(1),
              streamF.skip(1),
              streamG.skip(1),
              combiner))
          .shareValueSeeded(combiner(
              streamA.value,
              streamB.value,
              streamC.value,
              streamD.value,
              streamE.value,
              streamF.value,
              streamG.value));

  /// Merges the given ValueObservables into one ValueObservable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The new ValueObservable will be seeded based on the initial value of each input ValueObservable.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     final foo = ValueObservable.combineLatest3(
  ///       new Observable.just("a").shareValueSeeded("a"),
  ///       new Observable.just("b").shareValueSeeded("b"),
  ///       new Observable.just("c").shareValueSeeded("c"),
  ///       new Observable.just("d").shareValueSeeded("d"),
  ///       new Observable.just("e").shareValueSeeded("e"),
  ///       new Observable.just("f").shareValueSeeded("f"),
  ///       new Observable.just("g").shareValueSeeded("g"),
  ///       new Observable.fromIterable(["h", "h"]).shareValueSeeded("h"),
  ///       (a, b, c, d, e, f, g, h) => a + b + c + d + e + f + g + h);
  ///
  ///     print(foo.value); // prints "abcdefgh"
  ///     foo.listen(print); //prints "abcdefgh", "abcdefgh"
  static ValueObservable<T> combineLatest8<A, B, C, D, E, F, G, H, T>(
          ValueObservable<A> streamA,
          ValueObservable<B> streamB,
          ValueObservable<C> streamC,
          ValueObservable<D> streamD,
          ValueObservable<E> streamE,
          ValueObservable<F> streamF,
          ValueObservable<G> streamG,
          ValueObservable<H> streamH,
          T combiner(A a, B b, C c, D d, E e, F f, G g, H h)) =>
      Observable<T>(
        CombineLatestStream.combine8(
          streamA.skip(1),
          streamB.skip(1),
          streamC.skip(1),
          streamD.skip(1),
          streamE.skip(1),
          streamF.skip(1),
          streamG.skip(1),
          streamH.skip(1),
          combiner,
        ),
      ).shareValueSeeded(combiner(
          streamA.value,
          streamB.value,
          streamC.value,
          streamD.value,
          streamE.value,
          streamF.value,
          streamG.value,
          streamH.value));

  /// Merges the given ValueObservables into one ValueObservable sequence by using the
  /// [combiner] function whenever any of the observable sequences emits an
  /// item.
  ///
  /// The new ValueObservable will be seeded based on the initial value of each input ValueObservable.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
  ///
  /// ### Example
  ///
  ///     final foo = ValueObservable.combineLatest3(
  ///       new Observable.just("a").shareValueSeeded("a"),
  ///       new Observable.just("b").shareValueSeeded("b"),
  ///       new Observable.just("c").shareValueSeeded("c"),
  ///       new Observable.just("d").shareValueSeeded("d"),
  ///       new Observable.just("e").shareValueSeeded("e"),
  ///       new Observable.just("f").shareValueSeeded("f"),
  ///       new Observable.just("g").shareValueSeeded("g"),
  ///       new Observable.just("h").shareValueSeeded("h"),
  ///       new Observable.fromIterable(["i", "i"]).shareValueSeeded("i"),
  ///       (a, b, c, d, e, f, g, h, i) => a + b + c + d + e + f + g + h + i);
  ///
  ///     print(foo.value); // prints "abcdefghi"
  ///     foo.listen(print); //prints "abcdefghi", "abcdefghi"
  static ValueObservable<T> combineLatest9<A, B, C, D, E, F, G, H, I, T>(
          ValueObservable<A> streamA,
          ValueObservable<B> streamB,
          ValueObservable<C> streamC,
          ValueObservable<D> streamD,
          ValueObservable<E> streamE,
          ValueObservable<F> streamF,
          ValueObservable<G> streamG,
          ValueObservable<H> streamH,
          ValueObservable<I> streamI,
          T combiner(A a, B b, C c, D d, E e, F f, G g, H h, I i)) =>
      Observable<T>(
        CombineLatestStream.combine9(
          streamA.skip(1),
          streamB.skip(1),
          streamC.skip(1),
          streamD.skip(1),
          streamE.skip(1),
          streamF.skip(1),
          streamG.skip(1),
          streamH.skip(1),
          streamI.skip(1),
          combiner,
        ),
      ).shareValueSeeded(combiner(
          streamA.value,
          streamB.value,
          streamC.value,
          streamD.value,
          streamE.value,
          streamF.value,
          streamG.value,
          streamH.value,
          streamI.value));
}
