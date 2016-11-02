import 'dart:async';

import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:rxdart/rxdart.dart' as rx;

void main() {
  RxBenchmark.main();
}

class RxBenchmark extends BenchmarkBase {

  const RxBenchmark() : super("Template");

  static void main() {
    new RxBenchmark().report();
  }

  @override void run() {
    Stream<int> _streamA = new Stream<int>.fromIterable(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    Stream<int> _streamB = new Stream<int>.fromIterable(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

    rx.observable(_streamA)
      .flatMapLatest((int value) => _streamB)
      .listen(null);
  }

  // Not measured: setup code executed before the benchmark runs.
  @override void setup() {}

  // Not measured: teardown code executed after the benchmark runs.
  @override void teardown() {}
}