import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:rxdart/rxdart.dart';

import 'benchmark_utils.dart';

void main() => CombineLatestBenchmark.main();

class CombineLatestBenchmark extends BenchmarkBase {
  CombineLatestBenchmark() : super("combineLatest");

  static void main() => CombineLatestBenchmark().report();

  @override
  void run() {
    Observable.combineLatest2(range(), range(), (int x, int y) => x + y)
        .listen(null);
  }
}
