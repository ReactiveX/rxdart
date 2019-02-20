import 'package:benchmark_harness/benchmark_harness.dart';

import 'benchmark_utils.dart';

void main() => PlainBenchmark.main();

class PlainBenchmark extends BenchmarkBase {
  const PlainBenchmark() : super("plain");

  static void main() => PlainBenchmark().report();

  @override
  void run() {
    range().listen(null);
  }
}
