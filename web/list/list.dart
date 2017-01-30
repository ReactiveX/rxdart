import 'dart:html';
import 'dart:js';
import 'dart:math';
import 'dart:async';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:faker/faker.dart';

const int count = 100;
const int rowHeight = 24;

num visibleRowCount() => (document.body.client.height ~/ rowHeight) + 3;

Observable<Event> _getResizeObservable() {
  final StreamController<Event> controller =
      new StreamController<Event>.broadcast();

  document.body.addEventListener('resize', controller.add);

  return observable(controller.stream);
}

Observable<Event> _getMouseObservable(String mouseEvent) {
  final StreamController<Event> controller =
      new StreamController<Event>.broadcast();

  document.body.addEventListener(mouseEvent, controller.add);

  return observable(controller.stream);
}

/* VIRTUAL LIST
 * ------------
 * no scrollbar, use mouse click -> drag to scroll, or the mouse wheel
 */
void main() {
  // generate fake data
  final List<Person> fakePeople = new List<Person>.generate(
      count,
      (int index) => new Person(index,
          '${new Faker().person.firstName()} ${new Faker().person.lastName()}'))
    ..sort((Person P1, Person P2) => P1.name.compareTo(P2.name));

  // init react
  final _ListRenderer renderer = new _ListRenderer();

  setClientConfiguration();

  react.render(
      react.registerComponent(() => renderer)(const <dynamic, dynamic>{}),
      querySelector('#content'));

  // Rx
  final Observable<Event> resize = _getResizeObservable();
  final Observable<MouseEvent> mouseDown = _getMouseObservable('mousedown');
  final Observable<MouseEvent> mouseUp = _getMouseObservable('mouseup');
  final Observable<MouseEvent> mouseMove = _getMouseObservable('mousemove');
  final Observable<WheelEvent> mouseWheel = _getMouseObservable('mousewheel');

  final Observable<num> dragOffset = new Observable<num>.merge(<Stream<num>>[
    mouseDown.flatMap((MouseEvent e) => mouseMove
        .bufferWithCount(2, 1)
        .map((Iterable<MouseEvent> f) => f.first.client.y - f.last.client.y)
        .takeUntil(mouseUp)),
    mouseWheel
        .tap((WheelEvent e) => e.preventDefault())
        .map((WheelEvent e) => (e.deltaY * -.075).toInt()),
    resize.map((_) => 0)
  ], asBroadcastStream: true)
      .startWith(0);

  final Observable<num> accumulatedOffset =
      dragOffset.scan((num a, num c, num index) {
    final num sum = a + c;
    final num tot = (fakePeople.length - 1) * rowHeight;
    final num max = tot - min(document.body.client.height, tot);

    return (sum < 0) ? 0 : (sum > max) ? max : sum;
  }, 0);

  final Observable<num> displayedIndices =
      resize.map((_) => visibleRowCount()).startWith(visibleRowCount());

  final Observable<Map<String, int>> displayedRange =
      Observable.combineLatest2(
          displayedIndices,
          accumulatedOffset,
          (num maxIndex, num offset) => <String, int>{
                'from': offset ~/ rowHeight,
                'to': maxIndex + offset ~/ rowHeight
              },
          asBroadcastStream: true);

  final Observable<List<Person>> displayedPeople = displayedRange
      .flatMap((Map<String, int> o) =>
          new Observable<List<Person>>.fromIterable(<List<Person>>[
            fakePeople.sublist(o['from'], min(o['to'], fakePeople.length))
          ]))
      .tap((List<Person> list) {});

  displayedIndices.listen(print);

  Observable
      .combineLatest2(
          displayedPeople,
          accumulatedOffset,
          (List<Person> people, num offset) =>
              <String, dynamic>{'people': people, 'offset': offset})
      .listen(renderer.setState);
}

class _ListRenderer extends react.Component {
  @override
  JsObject render() {
    final List<dynamic> children = <dynamic>[];
    final int offset = state['offset'];
    final List<Person> people = state['people'];
    final int toggle =
        (offset != null && ((offset ~/ rowHeight) % 2) == 0) ? 0 : 1;

    if (people == null)
      return react.div(
          <String, String>{'className': 'list-renderer'}, const <dynamic>[]);

    for (int i = 0, len = people.length; i < len; i++)
      children.add(react.div(<String, dynamic>{
        'className': 'item-renderer',
        'style': <String, String>{'height': '${rowHeight}px'}
      }, <dynamic>[
        react.div(<String, dynamic>{
          'className': (i % 2 == toggle)
              ? 'item-renderer-label even'
              : 'item-renderer-label odd',
          'style': <String, String>{'height': '${rowHeight}px'}
        }, people[i].name)
      ]));

    return react.div(<String, dynamic>{
      'className': 'list-renderer',
      'style': <String, String>{'top': '${-(offset % rowHeight) - rowHeight}px'}
    }, children);
  }
}

class Person {
  final int index;
  final String name;

  Person(this.index, this.name);

  @override
  String toString() => name;
}
