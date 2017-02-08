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
  var n = (arguments.length == 1) ? int.parse(arguments.first) : 10;

  /// the first 2 fibonacci numbers
  const seq1 = const IndexedPair(1, 1, 1);
  const seq2 = const IndexedPair(1, 1, 2);

  /// initial n[1,2] values
  Iterable<IndexedPair> start =
      n == 0 ? const [] : n == 1 ? const [seq1] : const [seq1, seq2];

  /// given that the first 2 numbers in the sequence don't need calculation...
  var m = n >= 2 ? n - 2 : 0;

  Observable
      .range(0, m)
      .skip(1)
      .scan((seq, _, __) => new IndexedPair.next(seq), seq2)
      .startWithMany(start)
      .map((seq) => seq.stringify())
      .listen(print, onDone: () => print('done!'));
}

class IndexedPair {
  final int n1, n2, index;

  const IndexedPair(this.n1, this.n2, this.index);

  factory IndexedPair.next(IndexedPair prev) =>
      new IndexedPair(prev.n2, prev.n1 + prev.n2, prev.index + 1);

  String stringify() => '$index: $n2';
}
