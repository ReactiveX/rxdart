## 0.20.0
  * Breaking Change: bufferCount had buggy behavior when using `startBufferEvery` (was `skip` previously)
  If you were relying on bufferCount with `skip` greater than 1 before, then you may have noticed 
  erroneous behavior.
  * Breaking Change: `repeat` is no longer an operator which simply repeats the last emitted event n-times,
  instead this is now an Observable factory method which takes a StreamFactory and a count parameter.
  This will cause each repeat cycle to create a fresh Observable sequence.
  * `mapTo` is a new operator, which works just like `map`, but instead of taking a mapper Function, it takes
  a single value where each event is mapped to.
  * Bugfix: switchIfEmpty now correctly calls onDone
  * combineLatest and zip can now take any amount of Streams:
    * combineLatest2-9 & zip2-9 functionality unchanged, but now use a new path for construction.
    * adds combineLatest and zipLatest which allows you to pass through an Iterable<Stream<T>> and a combiner that takes a List<T> when any source emits a change.
    * adds combineLatestList / zipList which allows you to take in an Iterable<Stream<T>> and emit a Observable<List<T>> with the values. Just a convenience factory if all you want is the list!
    * Constructors are provided by the Stream implementation directly
  * Bugfix: Subjects that are transformed will now correctly return a new Observable where isBroadcast is true (was false before)  
  * Remove deprecated operators which were replaced long ago: `bufferWithCount`, `windowWithCount`, `amb`, `flatMapLatest`

## 0.19.0

  * Breaking Change: Subjects `onCancel` function now returns `void` instead of `Future` to properly comply with the `StreamController` signature.
  * Bugfix: FlatMap operator properly calls onDone for all cases
  * Connectable Observable: An observable that can be listened to multiple times, and does not begin emitting values until the `connect` method is called
  * ValueObservable: A new interface that allows you to get the latest value emitted by an Observable.
    * Implemented by BehaviorSubject
    * Convert normal observables into ValueObservables via `publishValue` or `shareValue`
  * ReplayObservable: A new interface that allows you to get the values emitted by an Observable.
      * Implemented by ReplaySubject
      * Convert normal observables into ReplayObservables via `publishReplay` or `shareReplay`  

## 0.18.1

* Add `retryWhen` operator. Thanks to Razvan Lung (@long1eu)! This can be used for custom retry logic.

## 0.18.0

* Breaking Change: remove `retype` method, deprecated as part of Dart 2.
* Add `flatMapIterable`

## 0.17.0

* Breaking Change: `stream` property on Observable is now private.
  * Avoids API confusion
  * Simplifies Subject implementation
  * Require folks who are overriding the `stream` property to use a `super` constructor instead 
* Adds proper onPause and onResume handling for `amb`/`race`, `combineLatest`, `concat`, `concat_eager`, `merge`  and `zip`
* Add `switchLatest` operator
* Add errors and stacktraces to RetryError class
* Add `onErrorResume` and `onErrorRetryWith` operators. These allow folks to return a specific stream or value depending on the error that occurred. 

## 0.16.7

* Fix new buffer and window implementation for Flutter + Dart 2
* Subject now implements the Observable interface

## 0.16.6

* Rework for `buffer` and `window`, allow to schedule using a sampler
* added `buffer`
* added `bufferFuture`
* added `bufferTest`
* added `bufferTime`
* added `bufferWhen`
* added `window`
* added `windowFuture`
* added `windowTest`
* added `windowTime`
* added `windowWhen`
* added `onCount` sampler for `buffer` and `window`
* added `onFuture` sampler for `buffer` and `window`
* added `onTest` sampler for `buffer` and `window`
* added `onTime` sampler for `buffer` and `window`
* added `onStream` sampler for `buffer` and `window`

## 0.16.5

* Renames `amb` to `race`
* Renames `flatMapLatest` to `switchMap`
* Renames `bufferWithCount` to `bufferCount`
* Renames `windowWithCount` to `windowCount`

## 0.16.4

* Adds `bufferTime` transformer.
* Adds `windowTime` transformer.

## 0.16.3

* Adds `delay` transformer.

## 0.16.2

* Fix added events to `sink` are not processed correctly by `Subjects`.

## 0.16.1

* Fix `dematerialize` method for Dart 2.

## 0.16.0+2

* Add `value` to `BehaviorSubject`. Allows you to get the latest value emitted by the subject if it exists.
* Add `values` to `ReplayrSubject`. Allows you to get the values stored by the subject if any exists.

## 0.16.0+1

* Update Changelog

## 0.16.0

* **breaks backwards compatibility**, this release only works with Dart SDK >=2.0.0.
* Removed old `cast` in favour of the now native Stream cast method.
* Override `retype` to return an `Observable`.

## 0.15.1

* Add `exhaustMap` map to inner observable, ignore other values until that observable completes.
* Improved code to be dartdevc compatible.
* Add upper SDK version limit in pubspec

## 0.15.0

* Change `debounce` to emit the last item of the source stream as soon as the source stream completes.
* Ensure `debounce` does not keep open any addition async timers after it has been cancelled.

## 0.14.0+1

* Change `DoStreamTransformer` to return a `Future` on cancel for api compatibility. 

## 0.14.0

* Add `PublishSubject` (thanks to @pauldemarco)
* Fix bug with `doOnX` operators where callbacks were fired too often

## 0.13.1

* Fix error with FlatMapLatest where it was not properly cancelled in some scenarios
* Remove additional async methods on Stream handlers unless they're shown to solve a problem

## 0.13.0

* Remove `call` operator / `StreamTransformer` entirely
* Important bug fix: Errors thrown within any Stream or Operator will now be properly sent to the `StreamSubscription`.
* Improve overall handling of errors throughout the library to ensure they're handled correctly

## 0.12.0

* Added doOn* operators in place of `call`.
* Added `DoStreamTransformer` as a replacement for `CallStreamTransformer`
* Deprecated `call` and `CallStreamTransformer`. Please use the appropriate `doOnX` operator / transformer.
* Added `distinctUnique`. Emits items if they've never been emitted before. Same as to Rx#distinct.

## 0.11.0

* !!!Breaking Api Change!!!
    * Observable.groupBy has been removed in order to be compatible with the next version of the `Stream` class in Dart 1.24.0, which includes this method

## 0.10.2

* BugFix: The new Subject implementation no longer causes infinite loops when used with ng2 async pipes.

## 0.10.1

* Documentation fixes

## 0.10.0

* Api Changes
  * Observable
    * Remove all deprecated methods, including:
      * `observable` factory -- replaced by the constructor `new Observable()`
      * `combineLatest` -- replaced by Strong-Mode versions `combineLatest2` - `combineLatest9`
      * `zip` -- replaced by Strong-Mode versions `zip2` - `zip9`
    * Support `asObservable` conversion from Future-returning methods. e.g. `new Observable.fromIterable([1, 2]).first.asObservable()`
    * Max and Min now return a Future of the Max or Min value, rather than a stream of increasing or decreasing values.
    * Add `cast` operator
    * Remove `ConcatMapStreamTransformer` -- functionality is already supported by `asyncExpand`. Keep the `concatMap` method as an alias.
  * Subjects
    * BehaviourSubject has been renamed to BehaviorSubject
    * The subjects have been rewritten and include far more testing
    * In keeping with the Rx idea of Subjects, they are broadcast-only
* Documentation -- extensive documentation has been added to the library with explanations and examples for each Future, Stream & Transformer.
  * Docs detailing the differences between RxDart and raw Observables.
  
## 0.9.0

* Api Changes:
  * Convert all StreamTransformer factories to proper classes
    * Ensure these classes can be re-used multiple times
  * Retry has moved from an operator to a constructor. This is to ensure the stream can be properly re-constructed every time in the correct way.
  * Streams now properly enforce the single-subscription contract
* Include example Flutter app. To run it, please follow the instructions in the README.

## 0.8.3+1
* rename examples map to example

## 0.8.3
* added concatWith, zipWith, mergeWith, skipUntil
* cleanup of the examples folder
* cleanup of examples code
* added fibonacci example
* added search GitHub example

## 0.8.2+1
* moved repo into ReactiveX
* update readme badges accordingly

## 0.8.2
* added materialize/dematerialize
* added range (factory)
* added timer (factory)
* added timestamp
* added concatMap

## 0.8.1
* added never constructor
* added error constructor
* moved code coverage to [codecov.io](https://codecov.io/gh/frankpepermans/rxdart)

## 0.8.0
* BREAKING: tap is replaced by call(onData)
* added call, which can take any combination of the following event methods: 
onCancel, onData, onDone, onError, onListen, onPause, onResume

## 0.7.1+1
* improved the README file

## 0.7.1
* added ignoreElements
* added onErrorResumeNext
* added onErrorReturn
* added switchIfEmpty
* added empty factory constructor

## 0.7.0
* BREAKING: rename combineXXXLatest and zipXXX to a numbered equivalent,
for example: combineThreeLatest becomes combineLatest3
* internal refactoring, expose streams/stream transformers as a separate library

## 0.6.3+4
* changed ofType to use TypeToken

## 0.6.3+3
* added ofType

## 0.6.3+2
* added defaultIfEmpty

## 0.6.3+1
* changed concat, old concat is now concatEager, new concat behaves as expected

## 0.6.3
* Added withLatestFrom 
* Added defer ctr
(both thanks to [brianegan](https://github.com/brianegan "GitHub link"))

## 0.6.2
* Added just (thanks to [brianegan](https://github.com/brianegan "GitHub link"))
* Added groupBy
* Added amb

## 0.6.1
* Added concat

## 0.6.0
* BREAKING: startWith now takes just one parameter instead of an Iterable. To add multiple starting events, please use startWithMany.
* Added BehaviourSubject and ReplaySubject. These implement StreamController.
* BehaviourSubject will notify the last added event upon listening.
* ReplaySubject will notify all past events upon listening.
* DEPRECATED: zip and combineLatest, use their strong-type-friendly alternatives instead (available as static methods on the Observable class, i.e. Observable.combineThreeLatest, Observable.zipFour, ...)

## 0.5.1

* Added documentation (thanks to [dustinlessard-wf](https://github.com/dustinlessard-wf "GitHub link"))
* Fix tests breaking due to deprecation of expectAsync
* Fix tests to satisfy strong mode requirements

## 0.5.0

* As of this version, rxdart depends on SDK v1.21.0, to support the newly added generic method type syntax

