import 'package:rxdart/rxdart.dart';

/// generate [n] fibonacci numbers
///
/// for example: dart fibonacci.dart 10
/// outputs:
/// 1: 1
/// 2: 1
/// 3: 2
/// 4: 3
/// 5: 5
/// 6: 8
/// 7: 13
/// 8: 21
/// 9: 34
/// 10: 55
/// done!
void main(List<String> arguments) {
  /// read the command line argument, if none provided, default to 10
  int n = (arguments.length == 1) ? int.parse(arguments.first) : 10;

  /// initial n[1,2] values
  final Iterable<String> start = n == 0
      ? const <String>[]
      : n == 1 ? const <String>['1: 1'] : const <String>['1: 1', '2: 1'];

  /// given that the first 2 numbers in the sequence don't need calculation...
  final int m = n >= 2 ? n - 2 : 0;

  IndexedPair accumulator(IndexedPair seq, _, __) => new IndexedPair.next(seq);

  Observable
      .range(0, m)
      .skip(1)
      .scan(accumulator, const IndexedPair(1, 1, 2))
      .map((IndexedPair seq) => seq.stringify())
      .startWithMany(start)
      .listen(print, onDone: () => print('done!'));
}

class IndexedPair {
  final int n1, n2, index;

  const IndexedPair(this.n1, this.n2, this.index);

  factory IndexedPair.next(IndexedPair prev) =>
      new IndexedPair(prev.n2, prev.n1 + prev.n2, prev.index + 1);

  String stringify() => '$index: $n2';
}
