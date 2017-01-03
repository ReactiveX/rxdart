## 0.6.0
* BREAKING: startWith now takes just one parameter instead of an Iterable. To add multiple starting events, please use startWithMany.
* Added BehaviourSubject and ReplaySubject. These implement StreamController.
* BehaviourSubject will notify the last added event upon listening.
* ReplaySubject will notify all past events upon listening.
* DEPRECATED: zip and combineLatest, use their strong-type-friendly alternatives instead (available as static methods on the Observable class, i.e. Observable.combineThreeLatest, Observable.zipFour, ...)

## 0.5.1

* Added documentation (thanks to dustinlessard-wf)
* Fix tests breaking due to deprecation of expectAsync
* Fix tests to satisfy strong mode requirements

## 0.5.0

* As of this version, rxdart depends on SDK v1.21.0, to support the newly added generic method type syntax

