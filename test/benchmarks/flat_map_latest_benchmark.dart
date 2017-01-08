import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:rxdart/rxdart.dart' as rx;

import 'benchmark_utils.dart';

void main() => FlatMapLatestBenchmark.main();

class FlatMapLatestBenchmark extends BenchmarkBase {

  FlatMapLatestBenchmark() : super("flatMapLatest");

  static void main() => new FlatMapLatestBenchmark().report();

  @override void run() {
    rx.observable(range())
        .flatMapLatest((int i) => range())
        .listen(null);
  }
}