import 'package:github_search/github_api.dart';

// The State represents the data the View requires. The View consumes a Stream
// of States. The view rebuilds every time the Stream emits a new State!
//
// The State Stream will emit new States depending on the situation: The
// initial state, loading states, the list of results, and any errors that
// happen.
//
// The State Stream responds to input from the View by accepting a
// Stream<String>. We call this Stream the onTextChanged "intent".
class SearchState {
  final SearchResult result;
  final bool hasError;
  final bool isLoading;

  SearchState({
    this.result,
    this.hasError = false,
    this.isLoading = false,
  });

  factory SearchState.initial() =>
      new SearchState(result: new SearchResult.noTerm());

  factory SearchState.loading() => new SearchState(isLoading: true);

  factory SearchState.error() => new SearchState(hasError: true);
}
