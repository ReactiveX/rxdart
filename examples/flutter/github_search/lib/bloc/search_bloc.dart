import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../api/github_api.dart';
import 'search_state.dart';

class SearchBloc {
  final Sink<String> onTextChanged;
  final ValueStream<SearchState> state;

  final StreamSubscription<void> _subscription;

  factory SearchBloc(GithubApi api) {
    final onTextChanged = PublishSubject<String>();

    final state = onTextChanged
        // If the text has not changed, do not perform a new search
        .distinct()
        // Wait for the user to stop typing for 250ms before running a search
        .debounceTime(const Duration(milliseconds: 250))
        // Call the Github api with the given search term and convert it to a
        // State. If another search term is entered, switchMap will ensure
        // the previous search is discarded so we don't deliver stale results
        // to the View.
        .switchMap<SearchState>((String term) => _search(term, api))
        // The initial state to deliver to the screen.
        .publishValueSeeded(const SearchNoTerm());

    final subscription = state.connect();

    return SearchBloc._(onTextChanged, state, subscription);
  }

  SearchBloc._(this.onTextChanged, this.state, this._subscription);

  void dispose() {
    _subscription.cancel();
    onTextChanged.close();
  }

  static Stream<SearchState> _search(String term, GithubApi api) => term.isEmpty
      ? Stream.value(const SearchNoTerm())
      : Rx.fromCallable(() => api.search(term))
          .map((result) =>
              result.isEmpty ? const SearchEmpty() : SearchPopulated(result))
          .startWith(const SearchLoading())
          .onErrorReturn(const SearchError());
}
