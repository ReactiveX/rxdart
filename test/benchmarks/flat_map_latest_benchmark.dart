import 'package:benchmark_harness/benchmark_harness.dart';

import 'benchmark_utils.dart';

void main() => SwitchMapBenchmark.main();

class SwitchMapBenchmark extends BenchmarkBase {
  SwitchMapBenchmark() : super("switchMap");

  static void main() => new SwitchMapBenchmark().report();

  @override
  void run() {
    range().switchMap((int i) => range()).listen(null);
  }
}
