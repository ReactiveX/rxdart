import 'dart:html';
import 'dart:math';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';
import 'package:rxdart/rxdart.dart' as Rx;
import 'package:faker/faker.dart';

const int count = 5000;
const int rowHeight = 24;

void main() {
  // generate fake data
  final List<Person> fakePeople = new List<Person>.generate(count, (int index) => new Person(index, '${new Faker().person.firstName()} ${new Faker().person.lastName()}'))
    ..sort((Person P1, Person P2) => P1.name.compareTo(P2.name));
  
  // init react
  final _ListRenderer renderer = new _ListRenderer();
  
  setClientConfiguration();
  
  react.render(react.registerComponent(() => renderer)({}), querySelector('#content'));
  
  // Rx
  final Rx.Observable<Event> resize = new Rx.Observable<Event>.fromEvent(window, 'resize');
  final Rx.Observable<MouseEvent> mouseDown = new Rx.Observable<MouseEvent>.fromEvent(document.body, 'mousedown');
  final Rx.Observable<MouseEvent> mouseUp = new Rx.Observable<MouseEvent>.fromEvent(document.body, 'mouseup');
  final Rx.Observable<MouseEvent> mouseMove = new Rx.Observable<MouseEvent>.fromEvent(document.body, 'mousemove');
  final Rx.Observable<WheelEvent> mouseWheel = new Rx.Observable<WheelEvent>.fromEvent(document.body, 'mousewheel');
  
  final Rx.Observable<int> dragOffset = new Rx.Observable.merge([
    mouseDown
      .flatMap((e) => mouseMove
          .bufferWithCount(2, 1)
          .map((f) => f.first.client.y - f.last.client.y)
          .takeUntil(mouseUp)),
    mouseWheel
      .tap((e) => e.preventDefault())
      .map((e) => (e.deltaY * -.075).toInt())
  ]).startWith([0]);
    
  final Rx.Observable<int> listDisplayedIndices = resize
    .map((Event e) => (document.body.client.height ~/ rowHeight) + 3)
    .startWith([(document.body.client.height ~/ rowHeight) + 3]);
  
  final Rx.Observable<int> accumulatedOffset = dragOffset
    .scan((int a, c, index) => (a + c < 0) ? 0 : a + c, 0);
  
  final Rx.Observable<List<int>> listOffset = new Rx.Observable.combineLatest([
    listDisplayedIndices,
    accumulatedOffset
  ], (int maxIndex, int offset) => [offset ~/ rowHeight, maxIndex + offset ~/ rowHeight]);
  
  final Rx.Observable<List<Person>> displayedPeople = listOffset
    .flatMap((o) => new Rx.Observable.just(fakePeople.sublist(o.first, min(o.last, fakePeople.length))));
  
  new Rx.Observable.combineLatest([
    accumulatedOffset,
    displayedPeople
  ], (int acc, List<Person> people) => {'acc': acc, 'people': people})
    .subscribe(renderer.setState);
}

class _ListRenderer extends react.Component {
  
  render() {
    final List children = [];
    final int acc = state['acc'];
    final List<Person> people = state['people'];
    final int toggle = (acc != null && ((acc ~/ rowHeight) % 2) == 0) ? 0 : 1;
    
    if (people == null) return react.div({'className': 'list-renderer'}, []);
    
    for (int i=0, len=people.length; i<len; i++)
      children.add(react.div({'className': 'item-renderer', 'style': {'height': '${rowHeight}px'}}, [react.div({
        'className': (i % 2 == toggle) ? 'item-renderer-label even' : 'item-renderer-label odd', 
        'style': {'height': '${rowHeight}px'}
      }, people[i].name)]));
    
    return react.div({
      'className': 'list-renderer',
      'style': {'top': '${-(acc % rowHeight) - rowHeight}px'}
    }, children);
  }
}

class Person {
  
  final int index;
  final String name;
  
  Person(this.index, this.name);
  
  String toString() => name;
  
}