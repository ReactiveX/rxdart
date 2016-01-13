import 'dart:async';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:rxdart/rxdart.dart' as rx;

class TemplateBenchmark extends BenchmarkBase {
  const TemplateBenchmark() : super("Template");

  static void main() {
    new TemplateBenchmark().report();
  }

  // The benchmark code.
  void run() {
    final Stream<int> stream = _getStream();
    final rx.Observable<int> observable = rx.observable(stream);

    observable
      .where((int i) => i % 2 == 0)
      .map((int i) => i * i)
      .bufferWithCount(2)
      .map((List<int> buffer) => {'first': buffer.first, 'last': buffer.last})
      .scan((int acc, Map<String, int> value, int index) => value['first'] + value['last'])
      .flatMap((_) => _getStream())
      .listen((_) {});
  }

  // Not measured: setup code executed before the benchmark runs.
  void setup() {
  }

  // Not measured: teardown code executed after the benchmark runs.
  void teardown() { }

  Stream<int> _getStream() async* {
    for (int i=0; i<100; i++) yield i;
  }
}

// Main function runs the benchmark.
main() {
  // Run TemplateBenchmark.
  TemplateBenchmark.main();
}
