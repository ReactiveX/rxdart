import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';
import 'package:rxdart/rxdart.dart' as Rx;
import 'package:faker/faker.dart';

const int rowHeight = 24;

void main() {
  const count = 100000;
  final List<Person> fakePeople = new List<Person>.generate(count, (int index) => new Person(index, '${new Faker().person.firstName()} ${new Faker().person.lastName()}'));
  final _ListRenderer renderer = new _ListRenderer();
  
  setClientConfiguration();
  
  react.render(react.registerComponent(() => renderer)({}), querySelector('#content'));
  
  final Rx.Observable<Event> resize = new Rx.Observable<Event>.fromEvent(window, 'resize');
  final Rx.Observable<MouseEvent> mouseDown = new Rx.Observable<MouseEvent>.fromEvent(document.body, 'mousedown');
  final Rx.Observable<MouseEvent> mouseUp = new Rx.Observable<MouseEvent>.fromEvent(document.body, 'mouseup');
  final Rx.Observable<MouseEvent> mouseMove = new Rx.Observable<MouseEvent>.fromEvent(document.body, 'mousemove');
  final Rx.Observable<WheelEvent> mouseWheel = new Rx.Observable<WheelEvent>.fromEvent(document.body, 'mousewheel');
  
  final Rx.Observable<int> mouseDragOffset = mouseDown
    .flatMap((e) => new Rx.Observable.merge([
      mouseMove
        .bufferWithCount(2, 1)
        .map((f) => f.first.client.y - f.last.client.y)
        .takeUntil(mouseUp),
      mouseWheel
        .tap((e) => e.preventDefault())
        .map((e) => (e.deltaY * -.05).toInt())
    ]))
    .startWith([0]);
    
  final Rx.Observable<int> listDisplayedIndices = resize
    .map((Event e) => (document.body.client.height ~/ rowHeight) + 3)
    .startWith([(document.body.client.height ~/ rowHeight) + 3]);
  
  final Rx.Observable<int> accumulatedOffset = mouseDragOffset
    .scan((int a, int c, int index) {
      int sum = a + c;
      
      return (sum < 0) ? 0 : sum;
    }, 0);
  
  final Rx.Observable<List<int>> listOffset = new Rx.Observable<List<int>>.combineLatest([
    listDisplayedIndices,
    accumulatedOffset
  ], (int maxIndex, int offset) => [offset ~/ rowHeight, maxIndex + offset ~/ rowHeight]);
  
  final Rx.Observable<List<Person>> displayedPersons = listOffset
    .flatMap((List<int> offsets) => new Rx.Observable.from([fakePeople.sublist(offsets.first, offsets.last)]));
  
  new Rx.Observable.combineLatest([
    accumulatedOffset,
    accumulatedOffset
      .map((i) => i % rowHeight),
    displayedPersons
  ], (int acc, int offset, List<Person> persons) => {'acc': acc, 'offset': -offset, 'persons': persons})
  .subscribe((Map<String, dynamic> i) => renderer.setState(i));
}

class _ListRenderer extends react.Component {
  
  getInitialState() => {
    'offset': 0,
    'persons': []
  };
  
  render() {
    final List children = [];
    final int acc = state['acc'];
    final int offset = state['offset'];
    final List<Person> people = state['persons'];
    final int toggle = (acc != null && ((acc ~/ rowHeight) % 2) == 0) ? 0 : 1;
    
    if (people == null) return react.div({
      'className': 'list-renderer'
    }, []);
    
    for (int i=0, len=people.length; i<len; i++) {
      final Map styles = {'className': 'item-renderer-label', 'style': {'height': '${rowHeight}px'}};
      
      styles['className'] = (i % 2 == toggle) ? 'item-renderer-label even' : 'item-renderer-label odd';
      
      children.add(react.div({'className': 'item-renderer', 'style': {'height': '${rowHeight}px'}}, [react.div(styles, people[i].name)]));
    }
    
    return react.div({
      'className': 'list-renderer',
      'style': {'top': '${offset - rowHeight}px'}
    }, children);
  }
}

class Person {
  
  final int index;
  final String name;
  
  Person(this.index, this.name);
  
  String toString() => name;
  
}