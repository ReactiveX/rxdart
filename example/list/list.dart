import 'dart:html';
import 'dart:math';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';
import 'package:rxdart/rxdart.dart' as Rx;
import 'package:faker/faker.dart';

const int count = 100;
const int rowHeight = 24;

int visibleRowCount() => (document.body.client.height ~/ rowHeight) + 3;

/* VIRTUAL LIST
 * ------------
 * no scrollbar, use mouse click -> drag to scroll, or the mouse wheel
 */
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
      .map((e) => (e.deltaY * -.075).toInt()),
    resize
      .map((_) => 0)
  ]).startWith([0]);
  
  final Rx.Observable<int> accumulatedOffset = dragOffset
    .scan((int a, c, index) {
      final int sum = a + c;
      final int tot = (fakePeople.length - 1) * rowHeight;
      final int max = tot - min(document.body.client.height, tot);
      
      return (sum < 0) ? 0 : (sum > max) ? max : sum;
    }, 0);
  
  final Rx.Observable<int> displayedIndices = resize
    .map((_) => visibleRowCount())
    .startWith([visibleRowCount()]);
  
  final Rx.Observable<Map<String, int>> displayedRange = new Rx.Observable.combineLatest([
    displayedIndices,
    accumulatedOffset
  ], (int maxIndex, int offset) => {'from': offset ~/ rowHeight, 'to': maxIndex + offset ~/ rowHeight});
  
  final Rx.Observable<List<Person>> displayedPeople = displayedRange
    .flatMap((o) => new Rx.Observable.just(fakePeople.sublist(o['from'], min(o['to'], fakePeople.length))));
  
  new Rx.Observable.combineLatest([
    displayedPeople,
    accumulatedOffset
  ], (List<Person> people, int offset) => {'offset': offset, 'people': people})
    .subscribe(renderer.setState);
}

class _ListRenderer extends react.Component {
  
  render() {
    final List children = [];
    final int offset = state['offset'];
    final List<Person> people = state['people'];
    final int toggle = (offset != null && ((offset ~/ rowHeight) % 2) == 0) ? 0 : 1;
    
    if (people == null) return react.div({'className': 'list-renderer'}, []);
    
    for (int i=0, len=people.length; i<len; i++)
      children.add(react.div({'className': 'item-renderer', 'style': {'height': '${rowHeight}px'}}, [react.div({
        'className': (i % 2 == toggle) ? 'item-renderer-label even' : 'item-renderer-label odd', 
        'style': {'height': '${rowHeight}px'}
      }, people[i].name)]));
    
    return react.div({
      'className': 'list-renderer',
      'style': {'top': '${-(offset % rowHeight) - rowHeight}px'}
    }, children);
  }
}

class Person {
  
  final int index;
  final String name;
  
  Person(this.index, this.name);
  
  String toString() => name;
  
}