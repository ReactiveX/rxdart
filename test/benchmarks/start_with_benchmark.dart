import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:rxdart/rxdart.dart' as rx;

import 'benchmark_utils.dart';

void main() => StartWithBenchmark.main();

class StartWithBenchmark extends BenchmarkBase {

  StartWithBenchmark() : super("startWith");

  static void main() => new StartWithBenchmark().report();

  @override void run() {
    range()
        .startWith(-1)
        .listen(null);
  }
}