import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';
import 'package:rxdart/rxdart.dart' as Rx;
import 'package:faker/faker.dart';

const int rowHeight = 22;

void main() {
  const count = 500;
  final List<String> fakeNames = new List<String>.generate(count, (_) => '${new Faker().person.firstName()} ${new Faker().person.lastName()}');
  final _ListRenderer renderer = new _ListRenderer();
  
  setClientConfiguration();
  
  react.render(react.registerComponent(() => renderer)({}), querySelector('#content'));
  
  final Rx.Observable<Person> dataStream = new Rx.Observable<int>.range(0, count)
     .map((i) => new Person(fakeNames[i]));
  
  final Rx.Observable<Event> resize = new Rx.Observable<Event>.fromEvent(window, 'resize');
  final Rx.Observable<MouseEvent> mouseDown = new Rx.Observable<MouseEvent>.fromEvent(document.body, 'mousedown');
  final Rx.Observable<MouseEvent> mouseUp = new Rx.Observable<MouseEvent>.fromEvent(document.body, 'mouseup');
  final Rx.Observable<MouseEvent> mouseMove = new Rx.Observable<MouseEvent>.fromEvent(document.body, 'mousemove');
  
  final Rx.Observable<int> mouseDragOffset = mouseDown
    .flatMap((e) => mouseMove
                    .bufferWithCount(2, 1)
                    .map((f) => f.first.client.y - f.last.client.y)
                    .takeUntil(mouseUp))
    .startWith([0]);
    
  final Rx.Observable<int> listDisplayedIndices = resize
    .map((Event e) => (document.body.client.height ~/ rowHeight) + 1)
    .startWith([(document.body.client.height ~/ rowHeight) + 1]);
  
  final Rx.Observable<int> accumulatedOffset = mouseDragOffset
    .scan((int a, int c, int index) => a + c, 0)
    .map((o) => (o < 0) ? 0 : o);
  
  final Rx.Observable<List<int>> listOffset = new Rx.Observable<List<int>>.combineLatest([
    listDisplayedIndices,
    accumulatedOffset
  ], (int maxIndex, int offset) => [offset ~/ rowHeight, maxIndex + offset ~/ rowHeight]);
  
  final Rx.Observable<List<Person>> displayedPersons = listOffset
    .flatMap((List<int> offsets) => dataStream.reduce((List<Person> a, Person c, int index) {
        if (index >= offsets.first && index < offsets.last) a.add(c);
        
        return a;
      }, <Person>[]));
  
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
      'style': {'top': '${offset}px'}
    }, children);
  }
}

class Person {
  
  final String name;
  
  Person(this.name);
  
  String toString() => name;
  
}