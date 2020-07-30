import 'package:rxdart/rxdart.dart';

void main() async {
//  var s = BehaviorSubjectWithOnErrorCallback<int>.seeded(
//    3,
//    callback: () => print('before add error'),
//  );
//  s.stream.listen(print, onError: print);
//  s.add(1);
//  s.addError(Exception());
//  s.addError(Exception());

  final query$ = PublishSubject<String>();
  final suggestionItems$ = BehaviorSubject.seeded(<String>[]);

  Stream<List<String>> _requestSuggestions(String query) async* {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    yield List.generate(2, (i) => "'Suggest query=$query, i=$i'");
  }

  query$
      .throttleTime(const Duration(milliseconds: 500), trailing: true, leading: true)
      .doOnData((q) => print('Emits $q'))
      .switchMap((q) => _requestSuggestions(q))
      .listen((items) => suggestionItems$.add(items));

  for (var i = 0; i < 100; i++) {
    query$.add('Query $i');
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }
  // 0 - 1 - 2 - 3 - 4 - 5
}

class BehaviorSubjectWithOnErrorCallback<T> extends Subject<T>
    implements ValueStream<T> {
  final void Function() _callback;
  final BehaviorSubject<T> _subject;

  factory BehaviorSubjectWithOnErrorCallback({
    void Function() callback,
    void Function() onListen,
    void Function() onCancel,
    bool sync = false,
  }) {
    return BehaviorSubjectWithOnErrorCallback._(callback,
        BehaviorSubject<T>(onListen: onListen, onCancel: onCancel, sync: sync));
  }

  factory BehaviorSubjectWithOnErrorCallback.seeded(
    T value, {
    void Function() callback,
    void Function() onListen,
    void Function() onCancel,
    bool sync = false,
  }) {
    return BehaviorSubjectWithOnErrorCallback._(
        callback,
        BehaviorSubject<T>.seeded(value,
            onListen: onListen, onCancel: onCancel, sync: sync));
  }

  BehaviorSubjectWithOnErrorCallback._(this._callback, this._subject)
      : super(_subject, _subject);

  @override
  void onAddError(Object error, [StackTrace stackTrace]) => _callback?.call();

  @override
  Object get error => _subject.error;

  @override
  bool get hasError => _subject.hasError;

  @override
  bool get hasValue => _subject.hasValue;

  @override
  T get value => _subject.value;
}
