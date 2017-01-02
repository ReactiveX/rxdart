import 'dart:async';

import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:rxdart/rxdart.dart' as rx;

void main() {
  RxBenchmark.main();
}

Iterable<int> list;

class RxBenchmark extends BenchmarkBase {

  const RxBenchmark() : super("Template");

  static void main() {
    new RxBenchmark().report();
  }

  @override void run() {
    rx.observable(new Stream<int>.fromIterable(list))
      .flatMapLatest((int value) => new Stream<int>.fromIterable(list))
      .listen(null);
  }

  // Not measured: setup code executed before the benchmark runs.
  @override void setup() {
    list = const <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  }

  // Not measured: teardown code executed after the benchmark runs.
  @override void teardown() {}
}