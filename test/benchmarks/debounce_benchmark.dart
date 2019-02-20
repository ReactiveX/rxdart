import 'package:benchmark_harness/benchmark_harness.dart';

import 'benchmark_utils.dart';

void main() => DebounceBenchmark.main();

class DebounceBenchmark extends BenchmarkBase {
  DebounceBenchmark() : super("debounce");

  static void main() => DebounceBenchmark().report();

  @override
  void run() {
    range().debounce(const Duration(milliseconds: 50)).listen(null);
  }
}
