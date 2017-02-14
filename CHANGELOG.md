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

