import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:rxdart/rxdart.dart' as rx;

import 'benchmark_utils.dart';

void main() => DebounceBenchmark.main();

class DebounceBenchmark extends BenchmarkBase {

  DebounceBenchmark() : super("debounce");

  static void main() => new DebounceBenchmark().report();

  @override void run() {
    rx.observable(range())
        .debounce(const Duration(milliseconds: 50))
        .listen(null);
  }
}