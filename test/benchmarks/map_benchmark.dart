import 'package:benchmark_harness/benchmark_harness.dart';

import 'benchmark_utils.dart';

void main() => MapBenchmark.main();

class MapBenchmark extends BenchmarkBase {
  MapBenchmark() : super("map");

  static void main() => new MapBenchmark().report();

  @override
  void run() {
    range().map((int i) => i + 1).listen(null);
  }
}
