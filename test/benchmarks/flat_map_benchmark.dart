import 'package:benchmark_harness/benchmark_harness.dart';

import 'benchmark_utils.dart';

void main() => FlatMapBenchmark.main();

class FlatMapBenchmark extends BenchmarkBase {
  FlatMapBenchmark() : super("flatMap");

  static void main() => FlatMapBenchmark().report();

  @override
  void run() {
    range().flatMap((int i) => range()).listen(null);
  }
}
