import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:rxdart/rxdart.dart' as rx;

import 'benchmark_utils.dart';

void main() => CombineLatestBenchmark.main();

class CombineLatestBenchmark extends BenchmarkBase {

  CombineLatestBenchmark() : super("combineLatest");

  static void main() => new CombineLatestBenchmark().report();

  @override void run() {
    rx.Observable.combineTwoLatest(
        range(),
        range(),
            (int x, int y) => x + y
    )
        .listen(null);
  }
}